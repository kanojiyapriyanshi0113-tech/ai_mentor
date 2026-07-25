package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

type ExamUsecase interface {
	ListExams(ctx context.Context) ([]entity.Exam, error)
	SelectExam(ctx context.Context, userID uuid.UUID, examID int) (*entity.Exam, error)
}

type examUsecase struct {
	examRepo repository.ExamRepository
}

func NewExamUsecase(examRepo repository.ExamRepository) ExamUsecase {
	return &examUsecase{examRepo: examRepo}
}

func (uc *examUsecase) ListExams(ctx context.Context) ([]entity.Exam, error) {
	exams, err := uc.examRepo.ListAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("list exams: %w", err)
	}
	return exams, nil
}

func (uc *examUsecase) SelectExam(ctx context.Context, userID uuid.UUID, examID int) (*entity.Exam, error) {
	exam, err := uc.examRepo.FindByID(ctx, examID)
	if err != nil {
		return nil, fmt.Errorf("find exam: %w", err)
	}
	if exam == nil {
		// Validation: reject selection of an exam id that doesn't exist
		// (e.g. a stale/removed exam id like the old JEE/NEET ids).
		return nil, apperror.ErrExamNotFound
	}

	if err := uc.examRepo.SelectExamForUser(ctx, userID, examID); err != nil {
		return nil, err
	}

	return exam, nil
}
