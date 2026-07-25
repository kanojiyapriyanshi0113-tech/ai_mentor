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

type subscriptionRepository struct{ db *pgxpool.Pool }

func NewSubscriptionRepository(db *pgxpool.Pool) *subscriptionRepository {
    return &subscriptionRepository{db: db}
}

func (r *subscriptionRepository) FindByUserID(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error) {
    const q = `SELECT id, user_id, plan_id, status, started_at, expires_at FROM subscriptions WHERE user_id = $1`
    var s entity.Subscription
    err := r.db.QueryRow(ctx, q, userID).Scan(&s.ID, &s.UserID, &s.PlanID, &s.Status, &s.StartedAt, &s.ExpiresAt)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("find subscription by user id: %w", err)
    }
    return &s, nil
}

func (r *subscriptionRepository) Upsert(ctx context.Context, sub *entity.Subscription) error {
    const q = `
        INSERT INTO subscriptions (user_id, plan_id, status, started_at, expires_at)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (user_id) DO UPDATE SET
            plan_id = EXCLUDED.plan_id, status = EXCLUDED.status,
            started_at = EXCLUDED.started_at, expires_at = EXCLUDED.expires_at, updated_at = now()
    `
    _, err := r.db.Exec(ctx, q, sub.UserID, sub.PlanID, sub.Status, sub.StartedAt, sub.ExpiresAt)
    if err != nil {
        return fmt.Errorf("upsert subscription: %w", err)
    }
    return nil
}