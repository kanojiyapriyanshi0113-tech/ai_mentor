package postgres

import (
    "context"
    "errors"
    "fmt"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
)

// CountStudents returns the total number of role=student users matching the
// same case-insensitive name/email search ListStudents applies, for
// pagination metadata.
func (r *adminRepository) CountStudents(ctx context.Context, search string) (int, error) {
    const q = `
        SELECT COUNT(*)
        FROM users
        WHERE role = 'student' AND ($1 = '' OR name ILIKE '%' || $1 || '%' OR email ILIKE '%' || $1 || '%')
    `
    var total int
    if err := r.db.QueryRow(ctx, q, search).Scan(&total); err != nil {
        return 0, fmt.Errorf("count students: %w", err)
    }
    return total, nil
}

// FindStudentByID returns the admin-facing view of a single student account.
func (r *adminRepository) FindStudentByID(ctx context.Context, id uuid.UUID) (*entity.StudentAccount, error) {
    const q = `
        SELECT id, name, email, is_blocked, premium, created_at
        FROM users WHERE id = $1 AND role = 'student'
    `
    var s entity.StudentAccount
    err := r.db.QueryRow(ctx, q, id.String()).
        Scan(&s.ID, &s.Name, &s.Email, &s.IsBlocked, &s.Premium, &s.CreatedAt)
    if errors.Is(err, pgx.ErrNoRows) {
        return nil, apperror.ErrStudentNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("find student: %w", err)
    }
    return &s, nil
}
