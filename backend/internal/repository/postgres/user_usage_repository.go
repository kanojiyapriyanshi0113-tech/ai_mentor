package postgres

import (
    "context"
    "errors"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"
)

type userUsageRepository struct{ db *pgxpool.Pool }

func NewUserUsageRepository(db *pgxpool.Pool) *userUsageRepository {
    return &userUsageRepository{db: db}
}

func (r *userUsageRepository) GetUsage(ctx context.Context, userID uuid.UUID, usageDate time.Time, featureKey string) (int, error) {
    const q = `SELECT used_count FROM user_usage WHERE user_id = $1 AND usage_date = $2 AND feature_key = $3`
    var used int
    err := r.db.QueryRow(ctx, q, userID, usageDate, featureKey).Scan(&used)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return 0, nil
        }
        return 0, fmt.Errorf("get usage: %w", err)
    }
    return used, nil
}

func (r *userUsageRepository) IncrementUsage(ctx context.Context, userID uuid.UUID, usageDate time.Time, featureKey string) error {
    const q = `
        INSERT INTO user_usage (user_id, usage_date, feature_key, used_count)
        VALUES ($1, $2, $3, 1)
        ON CONFLICT (user_id, usage_date, feature_key) DO UPDATE SET used_count = user_usage.used_count + 1
    `
    _, err := r.db.Exec(ctx, q, userID, usageDate, featureKey)
    if err != nil {
        return fmt.Errorf("increment usage: %w", err)
    }
    return nil
}