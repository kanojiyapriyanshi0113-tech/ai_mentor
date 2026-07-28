package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/entity"
)

// earningsRepository implements repository.EarningsRepository. Attribution
// is computed from user_lecture_progress (which student engaged with which
// teacher's batch) joined against payments, per the MVP revenue-share model
// described on entity.TeacherEarningsSummary.
type earningsRepository struct {
	db *pgxpool.Pool
}

func NewEarningsRepository(db *pgxpool.Pool) *earningsRepository {
	return &earningsRepository{db: db}
}

const defaultCommissionPercent = 50

func (r *earningsRepository) GetCommissionPercent(ctx context.Context, teacherID uuid.UUID) (int, error) {
	var percent int
	err := r.db.QueryRow(ctx,
		`SELECT commission_percent FROM teacher_commissions WHERE teacher_id = $1`,
		teacherID.String(),
	).Scan(&percent)
	if errors.Is(err, pgx.ErrNoRows) {
		return defaultCommissionPercent, nil
	}
	if err != nil {
		return 0, fmt.Errorf("get commission percent: %w", err)
	}
	return percent, nil
}

func (r *earningsRepository) SetCommissionPercent(ctx context.Context, teacherID uuid.UUID, percent int) error {
	const q = `
		INSERT INTO teacher_commissions (teacher_id, commission_percent, updated_at)
		VALUES ($1, $2, now())
		ON CONFLICT (teacher_id) DO UPDATE SET commission_percent = $2, updated_at = now()
	`
	if _, err := r.db.Exec(ctx, q, teacherID.String(), percent); err != nil {
		return fmt.Errorf("set commission percent: %w", err)
	}
	return nil
}

func (r *earningsRepository) CountTeacherStudents(ctx context.Context, teacherID uuid.UUID) (int, error) {
	const q = `
		SELECT COUNT(DISTINCT ulp.user_id)
		FROM user_lecture_progress ulp
		JOIN batches b ON b.id = ulp.batch_id
		WHERE b.teacher_id = $1
	`
	var count int
	if err := r.db.QueryRow(ctx, q, teacherID.String()).Scan(&count); err != nil {
		return 0, fmt.Errorf("count teacher students: %w", err)
	}
	return count, nil
}

func (r *earningsRepository) SumStudentPayments(ctx context.Context, teacherID uuid.UUID, monthKey string) (int, error) {
	q := `
		SELECT COALESCE(SUM(p.amount_paise), 0)
		FROM payments p
		WHERE p.status = 'success'
		  AND p.user_id IN (
			SELECT DISTINCT ulp.user_id
			FROM user_lecture_progress ulp
			JOIN batches b ON b.id = ulp.batch_id
			WHERE b.teacher_id = $1
		  )
	`
	args := []interface{}{teacherID.String()}
	if monthKey != "" {
		q += ` AND to_char(p.created_at, 'YYYY-MM') = $2`
		args = append(args, monthKey)
	}
	var total int
	if err := r.db.QueryRow(ctx, q, args...).Scan(&total); err != nil {
		return 0, fmt.Errorf("sum student payments: %w", err)
	}
	return total, nil
}

func (r *earningsRepository) RevenueHistory(ctx context.Context, teacherID uuid.UUID, months int) ([]entity.RevenueMonth, error) {
	if months <= 0 || months > 36 {
		months = 6
	}
	const q = `
		WITH attributed_students AS (
			SELECT DISTINCT ulp.user_id
			FROM user_lecture_progress ulp
			JOIN batches b ON b.id = ulp.batch_id
			WHERE b.teacher_id = $1
		),
		months AS (
			SELECT to_char(date_trunc('month', now()) - (n || ' months')::interval, 'YYYY-MM') AS month_key
			FROM generate_series(0, $2 - 1) AS n
		)
		SELECT m.month_key, COALESCE(SUM(p.amount_paise), 0)
		FROM months m
		LEFT JOIN payments p
			ON p.status = 'success'
			AND to_char(p.created_at, 'YYYY-MM') = m.month_key
			AND p.user_id IN (SELECT user_id FROM attributed_students)
		GROUP BY m.month_key
		ORDER BY m.month_key ASC
	`
	rows, err := r.db.Query(ctx, q, teacherID.String(), months)
	if err != nil {
		return nil, fmt.Errorf("revenue history: %w", err)
	}
	defer rows.Close()

	var out []entity.RevenueMonth
	for rows.Next() {
		var m entity.RevenueMonth
		if err := rows.Scan(&m.Month, &m.AmountPaise); err != nil {
			return nil, fmt.Errorf("scan revenue month: %w", err)
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

func (r *earningsRepository) SumPaidOut(ctx context.Context, teacherID uuid.UUID) (int, error) {
	const q = `SELECT COALESCE(SUM(amount_paise), 0) FROM teacher_payouts WHERE teacher_id = $1`
	var total int
	if err := r.db.QueryRow(ctx, q, teacherID.String()).Scan(&total); err != nil {
		return 0, fmt.Errorf("sum paid out: %w", err)
	}
	return total, nil
}

func (r *earningsRepository) ListPayouts(ctx context.Context, teacherID uuid.UUID, limit int) ([]entity.TeacherPayout, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	const q = `
		SELECT id, teacher_id, amount_paise, note, created_at
		FROM teacher_payouts
		WHERE teacher_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, q, teacherID.String(), limit)
	if err != nil {
		return nil, fmt.Errorf("list payouts: %w", err)
	}
	defer rows.Close()

	var out []entity.TeacherPayout
	for rows.Next() {
		var p entity.TeacherPayout
		if err := rows.Scan(&p.ID, &p.TeacherID, &p.AmountPaise, &p.Note, &p.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan payout: %w", err)
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// CreatePayout records a completed payout to a teacher and, in the same
// transaction, marks that teacher's currently-payable earnings ledger rows
// as paid and links them to this payout.
func (r *earningsRepository) CreatePayout(ctx context.Context, p *entity.TeacherPayout, paidBy uuid.UUID) error {
	if p.ID == "" {
		p.ID = uuid.New().String()
	}

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	const insertPayout = `
		INSERT INTO teacher_payouts (id, teacher_id, amount_paise, note, status, paid_by, created_at)
		VALUES ($1, $2, $3, $4, 'completed', $5, now())
	`
	if _, err := tx.Exec(ctx, insertPayout, p.ID, p.TeacherID, p.AmountPaise, p.Note, paidBy.String()); err != nil {
		return fmt.Errorf("create payout: %w", err)
	}

	const markEarningsPaid = `
		UPDATE teacher_earnings
		SET status = 'paid', payout_id = $1, updated_at = now()
		WHERE teacher_id = $2 AND status = 'payable' AND deleted_at IS NULL
	`
	if _, err := tx.Exec(ctx, markEarningsPaid, p.ID, p.TeacherID); err != nil {
		return fmt.Errorf("mark earnings paid: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit payout: %w", err)
	}
	return nil
}

func (r *earningsRepository) ListStudents(ctx context.Context, teacherID uuid.UUID) ([]entity.TeacherStudent, error) {
	const q = `
		SELECT u.id, u.name, u.email,
			array_agg(DISTINCT b.title) AS batch_titles,
			MAX(ulp.completed_at) AS last_active
		FROM user_lecture_progress ulp
		JOIN batches b ON b.id = ulp.batch_id
		JOIN users u ON u.id = ulp.user_id
		WHERE b.teacher_id = $1
		GROUP BY u.id, u.name, u.email
		ORDER BY last_active DESC
	`
	rows, err := r.db.Query(ctx, q, teacherID.String())
	if err != nil {
		return nil, fmt.Errorf("list teacher students: %w", err)
	}
	defer rows.Close()

	var out []entity.TeacherStudent
	for rows.Next() {
		var s entity.TeacherStudent
		if err := rows.Scan(&s.ID, &s.Name, &s.Email, &s.BatchTitles, &s.LastActive); err != nil {
			return nil, fmt.Errorf("scan teacher student: %w", err)
		}
		out = append(out, s)
	}
	return out, rows.Err()
}
