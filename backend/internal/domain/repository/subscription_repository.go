package repository

import (
    "context"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

type SubscriptionRepository interface {
    FindByUserID(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error)
    Upsert(ctx context.Context, sub *entity.Subscription) error
}