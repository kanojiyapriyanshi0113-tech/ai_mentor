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

type examRepository struct {
	db *pgxpool.Pool
}

func NewExamRepository(db *pgxpool.Pool) *examRepository {
	return &examRepository{db: db}
}

func (r *examRepository) ListAll(ctx context.Context) ([]entity.Exam, error) {
	const q = `SELECT id, code, name, category FROM exams ORDER BY category, id`
	rows, err := r.db.Query(ctx, q)
	if err != nil {
		return nil, fmt.Errorf("list exams: %w", err)
	}
	defer rows.Close()

	var exams []entity.Exam
	for rows.Next() {
		var e entity.Exam
		if err := rows.Scan(&e.ID, &e.Code, &e.Name, &e.Category); err != nil {
			return nil, fmt.Errorf("scan exam: %w", err)
		}
		exams = append(exams, e)
	}
	return exams, nil
}

func (r *examRepository) FindByID(ctx context.Context, id int) (*entity.Exam, error) {
	const q = `SELECT id, code, name, category FROM exams WHERE id = $1`
	var e entity.Exam
	err := r.db.QueryRow(ctx, q, id).Scan(&e.ID, &e.Code, &e.Name, &e.Category)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("find exam by id: %w", err)
	}
	return &e, nil
}

func (r *examRepository) SelectExamForUser(ctx context.Context, userID uuid.UUID, examID int) error {
	const q = `
        INSERT INTO user_exams (user_id, exam_id)
        VALUES ($1, $2)
        ON CONFLICT (user_id, exam_id) DO UPDATE SET selected_at = now()
    `
	_, err := r.db.Exec(ctx, q, userID, examID)
	if err != nil {
		return fmt.Errorf("select exam for user: %w", err)
	}
	return nil
}

func (r *examRepository) FindSelectedExamByUserID(ctx context.Context, userID uuid.UUID) (*entity.Exam, error) {
	const q = `
        SELECT e.id, e.code, e.name, e.category
        FROM user_exams ue
        JOIN exams e ON e.id = ue.exam_id
        WHERE ue.user_id = $1
        ORDER BY ue.selected_at DESC
        LIMIT 1
    `
	var e entity.Exam
	err := r.db.QueryRow(ctx, q, userID).Scan(&e.ID, &e.Code, &e.Name, &e.Category)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("find selected exam by user id: %w", err)
	}
	return &e, nil
}

