package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
)

// teacherPayoutRepository implements repository.TeacherPayoutRepository. It
// shares the teacher_payouts table with the Earnings module's
// earningsRepository, using the pending/paid lifecycle columns added for
// the Teacher Payout module.
type teacherPayoutRepository struct {
	db *pgxpool.Pool
}

func NewTeacherPayoutRepository(db *pgxpool.Pool) *teacherPayoutRepository {
	return &teacherPayoutRepository{db: db}
}

const teacherPayoutSelectColumns = `
	id, teacher_id, amount_paise, note, status, created_by, paid_by, paid_at, created_at, updated_at
`

func scanTeacherPayoutRecord(row pgx.Row) (*entity.TeacherPayoutRecord, error) {
	var p entity.TeacherPayoutRecord
	var createdBy *uuid.UUID
	if err := row.Scan(
		&p.ID, &p.TeacherID, &p.AmountPaise, &p.Note, &p.Status,
		&createdBy, &p.PaidBy, &p.PaidAt, &p.CreatedAt, &p.UpdatedAt,
	); err != nil {
		return nil, err
	}
	if createdBy != nil {
		p.CreatedBy = *createdBy
	}
	return &p, nil
}

func (r *teacherPayoutRepository) Create(ctx context.Context, p *entity.TeacherPayoutRecord) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	const q = `
		INSERT INTO teacher_payouts (id, teacher_id, amount_paise, note, status, created_by, created_at, updated_at)
		VALUES ($1, $2, $3, $4, 'pending', $5, now(), now())
		RETURNING created_at, updated_at
	`
	if err := r.db.QueryRow(ctx, q, p.ID, p.TeacherID, p.AmountPaise, p.Note, p.CreatedBy).
		Scan(&p.CreatedAt, &p.UpdatedAt); err != nil {
		return fmt.Errorf("create teacher payout: %w", err)
	}
	p.Status = entity.TeacherPayoutStatusPending
	return nil
}

func (r *teacherPayoutRepository) GetByID(ctx context.Context, id uuid.UUID) (*entity.TeacherPayoutRecord, error) {
	q := fmt.Sprintf(`SELECT %s FROM teacher_payouts WHERE id = $1`, teacherPayoutSelectColumns)
	p, err := scanTeacherPayoutRecord(r.db.QueryRow(ctx, q, id))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apperror.ErrPayoutNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("get teacher payout: %w", err)
	}
	return p, nil
}

// MarkPaid transitions a pending payout to paid and, in the same
// transaction, marks the teacher's currently-payable earnings ledger rows
// as paid and links them to this payout — mirroring how the Earnings
// module's CreatePayout settles the ledger, but deferred until the admin
// actually confirms payment.
func (r *teacherPayoutRepository) MarkPaid(ctx context.Context, id uuid.UUID, paidBy uuid.UUID) (*entity.TeacherPayoutRecord, error) {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)

	var status string
	var teacherID uuid.UUID
	err = tx.QueryRow(ctx, `SELECT status, teacher_id FROM teacher_payouts WHERE id = $1 FOR UPDATE`, id).
		Scan(&status, &teacherID)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apperror.ErrPayoutNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("lock teacher payout: %w", err)
	}
	if status != string(entity.TeacherPayoutStatusPending) {
		return nil, apperror.ErrPayoutAlreadyPaid
	}

	const updatePayout = `
		UPDATE teacher_payouts
		SET status = 'paid', paid_by = $1, paid_at = now(), updated_at = now()
		WHERE id = $2
	`
	if _, err := tx.Exec(ctx, updatePayout, paidBy, id); err != nil {
		return nil, fmt.Errorf("mark payout paid: %w", err)
	}

	const markEarningsPaid = `
		UPDATE teacher_earnings
		SET status = 'paid', payout_id = $1, updated_at = now()
		WHERE teacher_id = $2 AND status = 'payable' AND deleted_at IS NULL
	`
	if _, err := tx.Exec(ctx, markEarningsPaid, id, teacherID); err != nil {
		return nil, fmt.Errorf("mark earnings paid: %w", err)
	}

	q := fmt.Sprintf(`SELECT %s FROM teacher_payouts WHERE id = $1`, teacherPayoutSelectColumns)
	p, err := scanTeacherPayoutRecord(tx.QueryRow(ctx, q, id))
	if err != nil {
		return nil, fmt.Errorf("reload teacher payout: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, fmt.Errorf("commit mark paid: %w", err)
	}
	return p, nil
}

func (r *teacherPayoutRepository) ListAll(ctx context.Context, status string, teacherID *uuid.UUID, limit, offset int) ([]entity.TeacherPayoutRecord, error) {
	q := fmt.Sprintf(`SELECT %s FROM teacher_payouts WHERE 1 = 1`, teacherPayoutSelectColumns)
	args := []interface{}{}

	if status != "" {
		args = append(args, status)
		q += fmt.Sprintf(" AND status = $%d", len(args))
	}
	if teacherID != nil {
		args = append(args, *teacherID)
		q += fmt.Sprintf(" AND teacher_id = $%d", len(args))
	}

	args = append(args, limit)
	q += fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d", len(args))
	args = append(args, offset)
	q += fmt.Sprintf(" OFFSET $%d", len(args))

	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("list teacher payouts: %w", err)
	}
	defer rows.Close()
	return scanTeacherPayoutRecords(rows)
}

func (r *teacherPayoutRepository) ListByTeacher(ctx context.Context, teacherID uuid.UUID, limit, offset int) ([]entity.TeacherPayoutRecord, error) {
	q := fmt.Sprintf(`
		SELECT %s FROM teacher_payouts
		WHERE teacher_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, teacherPayoutSelectColumns)
	rows, err := r.db.Query(ctx, q, teacherID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("list teacher payout history: %w", err)
	}
	defer rows.Close()
	return scanTeacherPayoutRecords(rows)
}

func scanTeacherPayoutRecords(rows pgx.Rows) ([]entity.TeacherPayoutRecord, error) {
	out := make([]entity.TeacherPayoutRecord, 0)
	for rows.Next() {
		p, err := scanTeacherPayoutRecord(rows)
		if err != nil {
			return nil, fmt.Errorf("scan teacher payout: %w", err)
		}
		out = append(out, *p)
	}
	return out, rows.Err()
}
