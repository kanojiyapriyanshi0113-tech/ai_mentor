package postgres

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
)

// Update overwrites the editable fields of an application owned by userID,
// but only while it's still pending or changes_requested.
func (r *teacherApplicationRepository) Update(ctx context.Context, a *entity.TeacherApplication, userID uuid.UUID) error {
	const q = `
		UPDATE teacher_applications SET
			full_name = $1, email = $2, phone = $3, qualification = $4,
			experience_years = $5, exam_expertise = $6, subjects = $7, about = $8,
			resume_url = $9, degree_url = $10, govt_id_url = $11, photo_url = $12,
			demo_video_url = $13, expected_salary = $14, updated_at = now()
		WHERE id = $15 AND user_id = $16 AND status IN ('pending', 'changes_requested')
	`
	tag, err := r.db.Exec(ctx, q,
		a.FullName, a.Email, a.Phone, a.Qualification, a.ExperienceYears, a.ExamExpertise,
		a.Subjects, a.About, a.ResumeURL, a.DegreeURL, a.GovtIDURL, a.PhotoURL,
		a.DemoVideoURL, a.ExpectedSalary, a.ID, userID.String(),
	)
	if err != nil {
		return fmt.Errorf("update teacher application: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return apperror.ErrTeacherApplicationNotEditable
	}
	return nil
}

// Cancel withdraws the applicant's own application while it's still
// pending or changes_requested.
func (r *teacherApplicationRepository) Cancel(ctx context.Context, id uuid.UUID, userID uuid.UUID) error {
	const q = `
		UPDATE teacher_applications
		SET status = 'cancelled', updated_at = now()
		WHERE id = $1 AND user_id = $2 AND status IN ('pending', 'changes_requested')
	`
	tag, err := r.db.Exec(ctx, q, id.String(), userID.String())
	if err != nil {
		return fmt.Errorf("cancel teacher application: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return apperror.ErrTeacherApplicationNotEditable
	}
	return nil
}

// SearchList is List with an added case-insensitive name/email/phone search
// and a total row count for pagination.
func (r *teacherApplicationRepository) SearchList(ctx context.Context, status string, search string, limit, offset int) ([]entity.TeacherApplication, int, error) {
	base := `FROM teacher_applications WHERE 1 = 1`
	args := []interface{}{}

	if status != "" {
		args = append(args, status)
		base += fmt.Sprintf(" AND status = $%d", len(args))
	}
	if search != "" {
		args = append(args, "%"+search+"%")
		base += fmt.Sprintf(" AND (full_name ILIKE $%d OR email ILIKE $%d OR phone ILIKE $%d)", len(args), len(args), len(args))
	}

	var total int
	if err := r.db.QueryRow(ctx, `SELECT COUNT(*) `+base, args...).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("count teacher applications: %w", err)
	}

	args = append(args, limit, offset)
	q := `SELECT id, user_id, full_name, email, phone, qualification, experience_years, exam_expertise,
			subjects, about, resume_url, degree_url, govt_id_url, photo_url, demo_video_url,
			expected_salary, status, admin_note, COALESCE(reviewed_by::text, ''), reviewed_at, created_at, updated_at ` +
		base + fmt.Sprintf(" ORDER BY created_at DESC LIMIT $%d OFFSET $%d", len(args)-1, len(args))

	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("search teacher applications: %w", err)
	}
	defer rows.Close()

	var out []entity.TeacherApplication
	for rows.Next() {
		var a entity.TeacherApplication
		if err := rows.Scan(
			&a.ID, &a.UserID, &a.FullName, &a.Email, &a.Phone, &a.Qualification, &a.ExperienceYears,
			&a.ExamExpertise, &a.Subjects, &a.About, &a.ResumeURL, &a.DegreeURL, &a.GovtIDURL,
			&a.PhotoURL, &a.DemoVideoURL, &a.ExpectedSalary, &a.Status, &a.AdminNote, &a.ReviewedBy,
			&a.ReviewedAt, &a.CreatedAt, &a.UpdatedAt,
		); err != nil {
			return nil, 0, fmt.Errorf("scan teacher application: %w", err)
		}
		out = append(out, a)
	}
	return out, total, rows.Err()
}
