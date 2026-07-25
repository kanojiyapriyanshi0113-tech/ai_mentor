package repository

import (
    "context"

    "ai-mentor-backend/internal/domain/entity"
)

type PlanRepository interface {
    ListAll(ctx context.Context) ([]entity.Plan, error)
    FindByID(ctx context.Context, id int) (*entity.Plan, error)
    FindByCode(ctx context.Context, code string) (*entity.Plan, error)
}