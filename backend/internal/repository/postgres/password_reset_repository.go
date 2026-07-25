package postgres

import (
    "context"
    "errors"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/entity"
)

type passwordResetRepository struct {
    db *pgxpool.Pool
}

func NewPasswordResetRepository(db *pgxpool.Pool) *passwordResetRepository {
    return &passwordResetRepository{db: db}
}

func (r *passwordResetRepository) Create(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time) error {
    const q = `
        INSERT INTO password_reset_tokens (user_id, token_hash, expires_at)
        VALUES ($1, $2, $3)
    `
    _, err := r.db.Exec(ctx, q, userID, tokenHash, expiresAt)
    if err != nil {
        return fmt.Errorf("insert password reset token: %w", err)
    }
    return nil
}

func (r *passwordResetRepository) FindByTokenHash(ctx context.Context, tokenHash string) (*entity.PasswordResetToken, error) {
    const q = `
        SELECT id, user_id, token_hash, expires_at, used, created_at
        FROM password_reset_tokens WHERE token_hash = $1
    `
    var t entity.PasswordResetToken
    err := r.db.QueryRow(ctx, q, tokenHash).Scan(
        &t.ID, &t.UserID, &t.TokenHash, &t.ExpiresAt, &t.Used, &t.CreatedAt,
    )
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("find token by hash: %w", err)
    }
    return &t, nil
}

func (r *passwordResetRepository) MarkUsed(ctx context.Context, id string) error {
    const q = `UPDATE password_reset_tokens SET used = TRUE WHERE id = $1`
    _, err := r.db.Exec(ctx, q, id)
    if err != nil {
        return fmt.Errorf("mark token used: %w", err)
    }
    return nil
}
