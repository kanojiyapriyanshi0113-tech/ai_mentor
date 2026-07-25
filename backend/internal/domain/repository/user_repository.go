package repository

import (
    "context"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

type UserRepository interface {
    Create(ctx context.Context, u *entity.User) error
    FindByEmail(ctx context.Context, email string) (*entity.User, error)
    FindByID(ctx context.Context, id uuid.UUID) (*entity.User, error)
    ExistsByEmail(ctx context.Context, email string) (bool, error)
    UpdateName(ctx context.Context, id uuid.UUID, name string) error
    UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error
    UpdateRole(ctx context.Context, id uuid.UUID, role entity.Role) error
}
