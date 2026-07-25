package usecase

import (
    "context"
    "crypto/rand"
    "crypto/sha256"
    "encoding/hex"
    "fmt"
    "time"

    "golang.org/x/crypto/bcrypt"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/repository"
)

const resetTokenTTL = 30 * time.Minute

type PasswordResetUsecase interface {
    ForgotPassword(ctx context.Context, email string) (rawToken string, err error)
    ResetPassword(ctx context.Context, rawToken, newPassword string) error
}

type passwordResetUsecase struct {
    userRepo  repository.UserRepository
    resetRepo repository.PasswordResetRepository
}

func NewPasswordResetUsecase(userRepo repository.UserRepository, resetRepo repository.PasswordResetRepository) PasswordResetUsecase {
    return &passwordResetUsecase{userRepo: userRepo, resetRepo: resetRepo}
}

func generateRawToken() (string, error) {
    b := make([]byte, 32)
    if _, err := rand.Read(b); err != nil {
        return "", err
    }
    return hex.EncodeToString(b), nil
}

func hashToken(raw string) string {
    sum := sha256.Sum256([]byte(raw))
    return hex.EncodeToString(sum[:])
}

// ForgotPassword always returns nil error for unknown emails (no user enumeration).
// rawToken is empty if the email does not exist; caller should not leak this distinction to the client.
func (uc *passwordResetUsecase) ForgotPassword(ctx context.Context, email string) (string, error) {
    user, err := uc.userRepo.FindByEmail(ctx, email)
    if err != nil {
        return "", fmt.Errorf("find user by email: %w", err)
    }
    if user == nil {
        return "", nil
    }

    rawToken, err := generateRawToken()
    if err != nil {
        return "", fmt.Errorf("generate token: %w", err)
    }

    if err := uc.resetRepo.Create(ctx, user.ID, hashToken(rawToken), time.Now().Add(resetTokenTTL)); err != nil {
        return "", fmt.Errorf("store reset token: %w", err)
    }

    // TODO: send rawToken via email service. Returned here only for Day-1 stub/testing.
    return rawToken, nil
}

func (uc *passwordResetUsecase) ResetPassword(ctx context.Context, rawToken, newPassword string) error {
    tokenHash := hashToken(rawToken)

    t, err := uc.resetRepo.FindByTokenHash(ctx, tokenHash)
    if err != nil {
        return fmt.Errorf("find token: %w", err)
    }
    if t == nil || t.ExpiresAt.Before(time.Now()) {
        return apperror.ErrTokenInvalid
    }
    if t.Used {
        return apperror.ErrTokenUsed
    }

    hashed, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
    if err != nil {
        return fmt.Errorf("hash password: %w", err)
    }

    userID, err := uuidParse(t.UserID)
    if err != nil {
        return fmt.Errorf("parse user id: %w", err)
    }

    if err := uc.userRepo.UpdatePassword(ctx, userID, string(hashed)); err != nil {
        return fmt.Errorf("update password: %w", err)
    }

    if err := uc.resetRepo.MarkUsed(ctx, t.ID); err != nil {
        return fmt.Errorf("mark token used: %w", err)
    }

    return nil
}
