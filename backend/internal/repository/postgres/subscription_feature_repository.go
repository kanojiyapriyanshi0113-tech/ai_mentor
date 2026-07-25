package postgres

import (
    "context"
    "errors"
    "fmt"

    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/entity"
)

type subscriptionFeatureRepository struct{ db *pgxpool.Pool }

func NewSubscriptionFeatureRepository(db *pgxpool.Pool) *subscriptionFeatureRepository {
    return &subscriptionFeatureRepository{db: db}
}

func (r *subscriptionFeatureRepository) ListByPlanID(ctx context.Context, planID int) ([]entity.SubscriptionFeature, error) {
    const q = `SELECT plan_id, feature_key, feature_limit FROM subscription_features WHERE plan_id = $1`
    rows, err := r.db.Query(ctx, q, planID)
    if err != nil {
        return nil, fmt.Errorf("list subscription features: %w", err)
    }
    defer rows.Close()

    var features []entity.SubscriptionFeature
    for rows.Next() {
        var f entity.SubscriptionFeature
        if err := rows.Scan(&f.PlanID, &f.FeatureKey, &f.FeatureLimit); err != nil {
            return nil, fmt.Errorf("scan subscription feature: %w", err)
        }
        features = append(features, f)
    }
    return features, nil
}

func (r *subscriptionFeatureRepository) GetLimit(ctx context.Context, planID int, featureKey string) (int, error) {
    const q = `SELECT feature_limit FROM subscription_features WHERE plan_id = $1 AND feature_key = $2`
    var limit int
    err := r.db.QueryRow(ctx, q, planID, featureKey).Scan(&limit)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return 0, nil
        }
        return 0, fmt.Errorf("get feature limit: %w", err)
    }
    return limit, nil
}