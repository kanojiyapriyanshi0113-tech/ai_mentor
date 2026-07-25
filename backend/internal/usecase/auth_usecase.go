package usecase

import (
    "context"
    "fmt"
    "time"

    "github.com/google/uuid"
    "golang.org/x/crypto/bcrypt"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/domain/repository"
    "ai-mentor-backend/internal/infra/auth"
)

const (
    trialDuration = 7 * 24 * time.Hour
    jwtTTL        = 7 * 24 * time.Hour
)

type AuthUsecase interface {
    Register(ctx context.Context, name, email, password string) (token string, user *entity.User, err error)
    Login(ctx context.Context, email, password string) (token string, user *entity.User, err error)
}

type authUsecase struct {
    userRepo  repository.UserRepository
    jwtSecret string
}

func NewAuthUsecase(userRepo repository.UserRepository, jwtSecret string) AuthUsecase {
    return &authUsecase{userRepo: userRepo, jwtSecret: jwtSecret}
}

func (uc *authUsecase) Register(ctx context.Context, name, email, password string) (string, *entity.User, error) {
    exists, err := uc.userRepo.ExistsByEmail(ctx, email)
    if err != nil {
        return "", nil, fmt.Errorf("check email existence: %w", err)
    }
    if exists {
        return "", nil, apperror.ErrEmailAlreadyExists
    }

    hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    if err != nil {
        return "", nil, fmt.Errorf("hash password: %w", err)
    }

    now := time.Now()
    user := &entity.User{
        ID:             uuid.New(),
        Name:           name,
        Email:          email,
        PasswordHash:   string(hash),
        IsVerified:     false,
        Premium:        false,
        Role:           entity.RoleStudent,
        TrialStartDate: now,
        TrialEndDate:   now.Add(trialDuration),
        CreatedAt:      now,
        UpdatedAt:      now,
    }

    if err := uc.userRepo.Create(ctx, user); err != nil {
        return "", nil, err
    }

    token, err := auth.GenerateJWT(user.ID.String(), user.Role.String(), uc.jwtSecret, jwtTTL)
    if err != nil {
        return "", nil, fmt.Errorf("generate token: %w", err)
    }

    return token, user, nil
}

func (uc *authUsecase) Login(ctx context.Context, email, password string) (string, *entity.User, error) {
    user, err := uc.userRepo.FindByEmail(ctx, email)
    if err != nil {
        return "", nil, fmt.Errorf("find user by email: %w", err)
    }
    if user == nil || user.PasswordHash == "" {
        return "", nil, apperror.ErrInvalidCredentials
    }

    if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
        return "", nil, apperror.ErrInvalidCredentials
    }

    token, err := auth.GenerateJWT(user.ID.String(), user.Role.String(), uc.jwtSecret, jwtTTL)
    if err != nil {
        return "", nil, fmt.Errorf("generate token: %w", err)
    }

    return token, user, nil
}
