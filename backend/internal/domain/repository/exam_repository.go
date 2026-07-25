package repository

import (
    "context"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

type ExamRepository interface {
    ListAll(ctx context.Context) ([]entity.Exam, error)
    FindByID(ctx context.Context, id int) (*entity.Exam, error)
    SelectExamForUser(ctx context.Context, userID uuid.UUID, examID int) error
    FindSelectedExamByUserID(ctx context.Context, userID uuid.UUID) (*entity.Exam, error)
}
