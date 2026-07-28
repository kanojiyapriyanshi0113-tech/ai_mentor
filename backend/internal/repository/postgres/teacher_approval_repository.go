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

// ListPendingApplications returns pending "Become a Teacher" applications
// (oldest first) with a total count, for the admin Teacher Approval queue.
// Reuses the applicationColumns/scanApplication helpers already defined
// alongside teacherApplicationRepository.
func (r *teacherApplicationRepository) ListPendingApplications(ctx context.Context, limit, offset int) ([]entity.TeacherApplication, int, error) {
	var total int
	const countQ = `SELECT COUNT(*) FROM teacher_applications WHERE status = 'pending'`
	if err := r.db.QueryRow(ctx, countQ).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count pending teacher applications: %w", err)
	}

	q := `SELECT ` + applicationColumns + ` FROM teacher_applications WHERE status = 'pending' ORDER BY created_at ASC LIMIT $1 OFFSET $2`
	rows, err := r.db.Query(ctx, q, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("list pending teacher applications: %w", err)
	}
	defer rows.Close()

	var out []entity.TeacherApplication
	for rows.Next() {
		a, err := scanApplication(rows)
		if err != nil {
			return nil, 0, fmt.Errorf("scan teacher application: %w", err)
		}
		out = append(out, *a)
	}
	return out, total, rows.Err()
}

// FindTeacherByID returns the admin-facing view of a teacher account, used
// to confirm a target exists (and is actually a teacher) before suspending.
func (r *teacherApplicationRepository) FindTeacherByID(ctx context.Context, id uuid.UUID) (*entity.TeacherAccount, error) {
	const q = `
		SELECT id, name, email, is_approved, is_suspended, created_at
		FROM users WHERE id = $1 AND role = 'teacher'
	`
	var t entity.TeacherAccount
	err := r.db.QueryRow(ctx, q, id.String()).
		Scan(&t.ID, &t.Name, &t.Email, &t.IsApproved, &t.IsSuspended, &t.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apperror.ErrTeacherNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("find teacher: %w", err)
	}
	return &t, nil
}

// SetTeacherSuspension suspends (true) or reactivates (false) a teacher
// account.
func (r *teacherApplicationRepository) SetTeacherSuspension(ctx context.Context, id uuid.UUID, suspend bool) error {
	const q = `UPDATE users SET is_suspended = $1 WHERE id = $2 AND role = 'teacher'`
	tag, err := r.db.Exec(ctx, q, suspend, id.String())
	if err != nil {
		return fmt.Errorf("set teacher suspension: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return apperror.ErrTeacherNotFound
	}
	return nil
}
