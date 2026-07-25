package postgres

import (
"context"
"fmt"

"github.com/google/uuid"
"github.com/jackc/pgx/v5/pgxpool"
)

type userProgressRepository struct{ db *pgxpool.Pool }

func NewUserProgressRepository(db *pgxpool.Pool) *userProgressRepository {
return &userProgressRepository{db: db}
}

func (r *userProgressRepository) MarkComplete(ctx context.Context, userID uuid.UUID, featureKey string, ordinal int) error {
const q = `
INSERT INTO user_content_progress (user_id, feature_key, resource_ordinal)
VALUES ($1, $2, $3)
ON CONFLICT (user_id, feature_key, resource_ordinal) DO NOTHING
`
_, err := r.db.Exec(ctx, q, userID, featureKey, ordinal)
if err != nil {
return fmt.Errorf("mark complete: %w", err)
}
return nil
}

func (r *userProgressRepository) CountCompleted(ctx context.Context, userID uuid.UUID, featureKey string) (int, error) {
const q = `SELECT COUNT(*) FROM user_content_progress WHERE user_id = $1 AND feature_key = $2`
var count int
if err := r.db.QueryRow(ctx, q, userID, featureKey).Scan(&count); err != nil {
return 0, fmt.Errorf("count completed: %w", err)
}
return count, nil
}
