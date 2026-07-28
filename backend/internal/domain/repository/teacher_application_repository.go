package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

// TeacherApplicationRepository persists "Become a Teacher" applications.
type TeacherApplicationRepository interface {
	Create(ctx context.Context, a *entity.TeacherApplication) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.TeacherApplication, error)
	FindLatestByUserID(ctx context.Context, userID uuid.UUID) (*entity.TeacherApplication, error)
	HasOpenApplication(ctx context.Context, userID uuid.UUID) (bool, error)
	List(ctx context.Context, status string, limit, offset int) ([]entity.TeacherApplication, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status entity.ApplicationStatus, adminNote string, reviewedBy uuid.UUID) error
}