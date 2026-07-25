package repository

import (
    "context"

    "ai-mentor-backend/internal/domain/entity"
)

type SubscriptionFeatureRepository interface {
    ListByPlanID(ctx context.Context, planID int) ([]entity.SubscriptionFeature, error)
    GetLimit(ctx context.Context, planID int, featureKey string) (int, error)
}