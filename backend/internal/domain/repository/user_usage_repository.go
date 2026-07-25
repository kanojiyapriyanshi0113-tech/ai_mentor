package repository

import (
    "context"
    "time"

    "github.com/google/uuid"
)

type UserUsageRepository interface {
    GetUsage(ctx context.Context, userID uuid.UUID, usageDate time.Time, featureKey string) (int, error)
    IncrementUsage(ctx context.Context, userID uuid.UUID, usageDate time.Time, featureKey string) error
}