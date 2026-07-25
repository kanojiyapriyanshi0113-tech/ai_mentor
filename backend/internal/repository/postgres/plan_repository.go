package postgres

import (
    "context"
    "errors"
    "fmt"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/entity"
)

type planRepository struct{ db *pgxpool.Pool }

func NewPlanRepository(db *pgxpool.Pool) *planRepository { return &planRepository{db: db} }

func (r *planRepository) ListAll(ctx context.Context) ([]entity.Plan, error) {
    const q = `SELECT id, code, name, price_paise, duration_days, is_trial FROM plans ORDER BY price_paise`
    rows, err := r.db.Query(ctx, q)
    if err != nil {
        return nil, fmt.Errorf("list plans: %w", err)
    }
    defer rows.Close()

    var plans []entity.Plan
    for rows.Next() {
        var p entity.Plan
        if err := rows.Scan(&p.ID, &p.Code, &p.Name, &p.PricePaise, &p.DurationDays, &p.IsTrial); err != nil {
            return nil, fmt.Errorf("scan plan: %w", err)
        }
        plans = append(plans, p)
    }
    return plans, nil
}

func (r *planRepository) FindByID(ctx context.Context, id int) (*entity.Plan, error) {
    const q = `SELECT id, code, name, price_paise, duration_days, is_trial FROM plans WHERE id = $1`
    var p entity.Plan
    err := r.db.QueryRow(ctx, q, id).Scan(&p.ID, &p.Code, &p.Name, &p.PricePaise, &p.DurationDays, &p.IsTrial)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("find plan by id: %w", err)
    }
    return &p, nil
}

func (r *planRepository) FindByCode(ctx context.Context, code string) (*entity.Plan, error) {
    const q = `SELECT id, code, name, price_paise, duration_days, is_trial FROM plans WHERE code = $1`
    var p entity.Plan
    err := r.db.QueryRow(ctx, q, code).Scan(&p.ID, &p.Code, &p.Name, &p.PricePaise, &p.DurationDays, &p.IsTrial)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("find plan by code: %w", err)
    }
    return &p, nil
}