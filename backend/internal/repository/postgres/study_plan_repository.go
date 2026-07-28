package postgres

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/entity"
)

type studyPlanRepository struct {
	db *pgxpool.Pool
}

func NewStudyPlanRepository(db *pgxpool.Pool) *studyPlanRepository {
	return &studyPlanRepository{db: db}
}

func (r *studyPlanRepository) Create(ctx context.Context, plan *entity.StudyPlan) error {
	const q = `
		INSERT INTO study_plans (user_id, date, goal, is_completed)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at
	`
	err := r.db.QueryRow(ctx, q, plan.UserID, plan.Date, plan.Goal, plan.IsCompleted).
		Scan(&plan.ID, &plan.CreatedAt)
	if err != nil {
		return fmt.Errorf("insert study plan: %w", err)
	}
	return nil
}

func (r *studyPlanRepository) Update(ctx context.Context, planID, userID uuid.UUID, date time.Time, goal string, isCompleted bool) (*entity.StudyPlan, error) {
	const q = `
		UPDATE study_plans
		SET date = $1, goal = $2, is_completed = $3
		WHERE id = $4 AND user_id = $5
		RETURNING id, user_id, date, goal, is_completed, created_at
	`
	var p entity.StudyPlan
	err := r.db.QueryRow(ctx, q, date, goal, isCompleted, planID, userID).
		Scan(&p.ID, &p.UserID, &p.Date, &p.Goal, &p.IsCompleted, &p.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pgx.ErrNoRows
		}
		return nil, fmt.Errorf("update study plan: %w", err)
	}
	return &p, nil
}

func (r *studyPlanRepository) Delete(ctx context.Context, planID, userID uuid.UUID) error {
	const q = `DELETE FROM study_plans WHERE id = $1 AND user_id = $2`
	tag, err := r.db.Exec(ctx, q, planID, userID)
	if err != nil {
		return fmt.Errorf("delete study plan: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

func (r *studyPlanRepository) ListByUser(ctx context.Context, userID uuid.UUID) ([]entity.StudyPlan, error) {
	const q = `
		SELECT id, user_id, date, goal, is_completed, created_at
		FROM study_plans
		WHERE user_id = $1
		ORDER BY date DESC
	`
	rows, err := r.db.Query(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("list study plans: %w", err)
	}
	defer rows.Close()

	var plans []entity.StudyPlan
	for rows.Next() {
		var p entity.StudyPlan
		if err := rows.Scan(&p.ID, &p.UserID, &p.Date, &p.Goal, &p.IsCompleted, &p.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan study plan: %w", err)
		}
		plans = append(plans, p)
	}
	return plans, nil
}

func (r *studyPlanRepository) Complete(ctx context.Context, planID, userID uuid.UUID) (*entity.StudyPlan, error) {
	const q = `
		UPDATE study_plans
		SET is_completed = true
		WHERE id = $1 AND user_id = $2
		RETURNING id, user_id, date, goal, is_completed, created_at
	`
	var p entity.StudyPlan
	err := r.db.QueryRow(ctx, q, planID, userID).
		Scan(&p.ID, &p.UserID, &p.Date, &p.Goal, &p.IsCompleted, &p.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, pgx.ErrNoRows
		}
		return nil, fmt.Errorf("complete study plan: %w", err)
	}
	return &p, nil
}