package usecase

import (
    "context"
    "fmt"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/domain/repository"
)

type ProfileUsecase interface {
    GetProfile(ctx context.Context, userID uuid.UUID) (*entity.User, error)
    UpdateProfile(ctx context.Context, userID uuid.UUID, name string) (*entity.User, error)
}

type profileUsecase struct {
    userRepo repository.UserRepository
}

func NewProfileUsecase(userRepo repository.UserRepository) ProfileUsecase {
    return &profileUsecase{userRepo: userRepo}
}

func (uc *profileUsecase) GetProfile(ctx context.Context, userID uuid.UUID) (*entity.User, error) {
    user, err := uc.userRepo.FindByID(ctx, userID)
    if err != nil {
        return nil, fmt.Errorf("find user by id: %w", err)
    }
    return user, nil
}

func (uc *profileUsecase) UpdateProfile(ctx context.Context, userID uuid.UUID, name string) (*entity.User, error) {
    if err := uc.userRepo.UpdateName(ctx, userID, name); err != nil {
        return nil, err
    }
    return uc.userRepo.FindByID(ctx, userID)
}
