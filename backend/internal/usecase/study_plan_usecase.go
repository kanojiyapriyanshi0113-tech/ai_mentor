package usecase

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

type StudyPlanUsecase interface {
	ListPlans(ctx context.Context, userID uuid.UUID) ([]entity.StudyPlan, error)
	CreatePlan(ctx context.Context, userID uuid.UUID, date time.Time, goal string, isCompleted bool) (*entity.StudyPlan, error)
	UpdatePlan(ctx context.Context, userID, planID uuid.UUID, date time.Time, goal string, isCompleted bool) (*entity.StudyPlan, error)
	DeletePlan(ctx context.Context, userID, planID uuid.UUID) error
	CompletePlan(ctx context.Context, userID, planID uuid.UUID) (*entity.StudyPlan, error)
}

type studyPlanUsecase struct {
	planRepo repository.StudyPlanRepository
}

func NewStudyPlanUsecase(planRepo repository.StudyPlanRepository) StudyPlanUsecase {
	return &studyPlanUsecase{planRepo: planRepo}
}

func (uc *studyPlanUsecase) ListPlans(ctx context.Context, userID uuid.UUID) ([]entity.StudyPlan, error) {
	plans, err := uc.planRepo.ListByUser(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list plans: %w", err)
	}
	return plans, nil
}

func (uc *studyPlanUsecase) CreatePlan(ctx context.Context, userID uuid.UUID, date time.Time, goal string, isCompleted bool) (*entity.StudyPlan, error) {
	plan := &entity.StudyPlan{
		UserID:      userID.String(),
		Date:        date,
		Goal:        goal,
		IsCompleted: isCompleted,
	}
	if err := uc.planRepo.Create(ctx, plan); err != nil {
		return nil, fmt.Errorf("create plan: %w", err)
	}
	return plan, nil
}

func (uc *studyPlanUsecase) UpdatePlan(ctx context.Context, userID, planID uuid.UUID, date time.Time, goal string, isCompleted bool) (*entity.StudyPlan, error) {
	plan, err := uc.planRepo.Update(ctx, planID, userID, date, goal, isCompleted)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.ErrStudyPlanNotFound
		}
		return nil, fmt.Errorf("update plan: %w", err)
	}
	return plan, nil
}

func (uc *studyPlanUsecase) DeletePlan(ctx context.Context, userID, planID uuid.UUID) error {
	if err := uc.planRepo.Delete(ctx, planID, userID); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return apperror.ErrStudyPlanNotFound
		}
		return fmt.Errorf("delete plan: %w", err)
	}
	return nil
}

func (uc *studyPlanUsecase) CompletePlan(ctx context.Context, userID, planID uuid.UUID) (*entity.StudyPlan, error) {
	plan, err := uc.planRepo.Complete(ctx, userID, planID)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, apperror.ErrStudyPlanNotFound
		}
		return nil, fmt.Errorf("complete plan: %w", err)
	}
	return plan, nil
}