package repository

import (
	"context"
	"time"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

type StudyPlanRepository interface {
	Create(ctx context.Context, plan *entity.StudyPlan) error
	Update(ctx context.Context, planID, userID uuid.UUID, date time.Time, goal string, isCompleted bool) (*entity.StudyPlan, error)
	Delete(ctx context.Context, planID, userID uuid.UUID) error
	ListByUser(ctx context.Context, userID uuid.UUID) ([]entity.StudyPlan, error)
	Complete(ctx context.Context, planID, userID uuid.UUID) (*entity.StudyPlan, error)
}