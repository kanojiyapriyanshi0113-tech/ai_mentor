package postgres

import (
    "context"
    "errors"
    "fmt"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgconn"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
)

const uniqueViolationCode = "23505"

type userRepository struct {
    db *pgxpool.Pool
}

func NewUserRepository(db *pgxpool.Pool) *userRepository {
    return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, u *entity.User) error {
    role := u.Role
    if role == "" {
        role = entity.RoleStudent
    }
    const q = `
        INSERT INTO users (id, name, email, password_hash, is_verified, premium, role,
                            trial_start_date, trial_end_date, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    `
    _, err := r.db.Exec(ctx, q,
        u.ID, u.Name, u.Email, u.PasswordHash, u.IsVerified, u.Premium, string(role),
        u.TrialStartDate, u.TrialEndDate, u.CreatedAt, u.UpdatedAt,
    )
    if err != nil {
        var pgErr *pgconn.PgError
        if errors.As(err, &pgErr) && pgErr.Code == uniqueViolationCode {
            return apperror.ErrEmailAlreadyExists
        }
        return fmt.Errorf("insert user: %w", err)
    }
    return nil
}

func (r *userRepository) FindByEmail(ctx context.Context, email string) (*entity.User, error) {
    const q = `
        SELECT id, name, email, password_hash, is_verified, premium, role,
               trial_start_date, trial_end_date, created_at, updated_at
        FROM users WHERE email = $1
    `
    var u entity.User
    var role string
    err := r.db.QueryRow(ctx, q, email).Scan(
        &u.ID, &u.Name, &u.Email, &u.PasswordHash, &u.IsVerified, &u.Premium, &role,
        &u.TrialStartDate, &u.TrialEndDate, &u.CreatedAt, &u.UpdatedAt,
    )
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("find user by email: %w", err)
    }
    u.Role = entity.Role(role)
    return &u, nil
}

func (r *userRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.User, error) {
    const q = `
        SELECT id, name, email, password_hash, is_verified, premium, role,
               trial_start_date, trial_end_date, created_at, updated_at
        FROM users WHERE id = $1
    `
    var u entity.User
    var role string
    err := r.db.QueryRow(ctx, q, id).Scan(
        &u.ID, &u.Name, &u.Email, &u.PasswordHash, &u.IsVerified, &u.Premium, &role,
        &u.TrialStartDate, &u.TrialEndDate, &u.CreatedAt, &u.UpdatedAt,
    )
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("find user by id: %w", err)
    }
    u.Role = entity.Role(role)
    return &u, nil
}

func (r *userRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
    const q = `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)`
    var exists bool
    if err := r.db.QueryRow(ctx, q, email).Scan(&exists); err != nil {
        return false, fmt.Errorf("check email existence: %w", err)
    }
    return exists, nil
}

func (r *userRepository) UpdateName(ctx context.Context, id uuid.UUID, name string) error {
    const q = `UPDATE users SET name = $1 WHERE id = $2`
    tag, err := r.db.Exec(ctx, q, name, id)
    if err != nil {
        return fmt.Errorf("update user name: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrUserNotFound
    }
    return nil
}

func (r *userRepository) UpdatePassword(ctx context.Context, id uuid.UUID, passwordHash string) error {
    const q = `UPDATE users SET password_hash = $1 WHERE id = $2`
    tag, err := r.db.Exec(ctx, q, passwordHash, id)
    if err != nil {
        return fmt.Errorf("update user password: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrUserNotFound
    }
    return nil
}

func (r *userRepository) UpdateRole(ctx context.Context, id uuid.UUID, role entity.Role) error {
    const q = `UPDATE users SET role = $1 WHERE id = $2`
    tag, err := r.db.Exec(ctx, q, string(role), id)
    if err != nil {
        return fmt.Errorf("update user role: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrUserNotFound
    }
    return nil
}
