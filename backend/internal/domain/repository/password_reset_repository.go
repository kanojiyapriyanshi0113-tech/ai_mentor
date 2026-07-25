package repository

import (
    "context"
    "time"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

type PasswordResetRepository interface {
    Create(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time) error
    FindByTokenHash(ctx context.Context, tokenHash string) (*entity.PasswordResetToken, error)
    MarkUsed(ctx context.Context, id string) error
}
