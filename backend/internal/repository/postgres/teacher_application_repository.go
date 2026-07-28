package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
)

type teacherApplicationRepository struct {
	db *pgxpool.Pool
}

func NewTeacherApplicationRepository(db *pgxpool.Pool) *teacherApplicationRepository {
	return &teacherApplicationRepository{db: db}
}

const applicationColumns = `
	id, user_id, full_name, email, phone, qualification, experience_years,
	exam_expertise, subjects, about, resume_url, degree_url, govt_id_url,
	photo_url, demo_video_url, expected_salary, status, admin_note,
	COALESCE(reviewed_by::text, ''), reviewed_at, created_at, updated_at
`

func scanApplication(row pgx.Row) (*entity.TeacherApplication, error) {
	var a entity.TeacherApplication
	err := row.Scan(
		&a.ID, &a.UserID, &a.FullName, &a.Email, &a.Phone, &a.Qualification, &a.ExperienceYears,
		&a.ExamExpertise, &a.Subjects, &a.About, &a.ResumeURL, &a.DegreeURL, &a.GovtIDURL,
		&a.PhotoURL, &a.DemoVideoURL, &a.ExpectedSalary, &a.Status, &a.AdminNote,
		&a.ReviewedBy, &a.ReviewedAt, &a.CreatedAt, &a.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &a, nil
}

func (r *teacherApplicationRepository) Create(ctx context.Context, a *entity.TeacherApplication) error {
	if a.ID == "" {
		a.ID = uuid.New().String()
	}
	const q = `
		INSERT INTO teacher_applications (
			id, user_id, full_name, email, phone, qualification, experience_years,
			exam_expertise, subjects, about, resume_url, degree_url, govt_id_url,
			photo_url, demo_video_url, expected_salary, status, created_at, updated_at
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,'pending',now(),now())
	`
	_, err := r.db.Exec(ctx, q,
		a.ID, a.UserID, a.FullName, a.Email, a.Phone, a.Qualification, a.ExperienceYears,
		a.ExamExpertise, a.Subjects, a.About, a.ResumeURL, a.DegreeURL, a.GovtIDURL,
		a.PhotoURL, a.DemoVideoURL, a.ExpectedSalary,
	)
	if err != nil {
		return fmt.Errorf("create teacher application: %w", err)
	}
	return nil
}

func (r *teacherApplicationRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.TeacherApplication, error) {
	q := `SELECT ` + applicationColumns + ` FROM teacher_applications WHERE id = $1`
	a, err := scanApplication(r.db.QueryRow(ctx, q, id.String()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apperror.ErrTeacherApplicationNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("find teacher application: %w", err)
	}
	return a, nil
}

func (r *teacherApplicationRepository) FindLatestByUserID(ctx context.Context, userID uuid.UUID) (*entity.TeacherApplication, error) {
	q := `SELECT ` + applicationColumns + ` FROM teacher_applications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1`
	a, err := scanApplication(r.db.QueryRow(ctx, q, userID.String()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, apperror.ErrTeacherApplicationNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("find latest teacher application: %w", err)
	}
	return a, nil
}

func (r *teacherApplicationRepository) HasOpenApplication(ctx context.Context, userID uuid.UUID) (bool, error) {
	const q = `
		SELECT EXISTS(
			SELECT 1 FROM teacher_applications
			WHERE user_id = $1 AND status IN ('pending','changes_requested')
		)
	`
	var exists bool
	if err := r.db.QueryRow(ctx, q, userID.String()).Scan(&exists); err != nil {
		return false, fmt.Errorf("check open teacher application: %w", err)
	}
	return exists, nil
}

func (r *teacherApplicationRepository) List(ctx context.Context, status string, limit, offset int) ([]entity.TeacherApplication, error) {
	q := `SELECT ` + applicationColumns + ` FROM teacher_applications`
	args := []interface{}{}
	if status != "" {
		q += ` WHERE status = $1`
		args = append(args, status)
	}
	q += fmt.Sprintf(` ORDER BY created_at DESC LIMIT %d OFFSET %d`, limit, offset)

	rows, err := r.db.Query(ctx, q, args...)
	if err != nil {
		return nil, fmt.Errorf("list teacher applications: %w", err)
	}
	defer rows.Close()

	var out []entity.TeacherApplication
	for rows.Next() {
		a, err := scanApplication(rows)
		if err != nil {
			return nil, fmt.Errorf("scan teacher application: %w", err)
		}
		out = append(out, *a)
	}
	return out, rows.Err()
}

func (r *teacherApplicationRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status entity.ApplicationStatus, adminNote string, reviewedBy uuid.UUID) error {
	const q = `
		UPDATE teacher_applications
		SET status = $1, admin_note = $2, reviewed_by = $3, reviewed_at = now(), updated_at = now()
		WHERE id = $4
	`
	tag, err := r.db.Exec(ctx, q, string(status), adminNote, reviewedBy.String(), id.String())
	if err != nil {
		return fmt.Errorf("update teacher application status: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return apperror.ErrTeacherApplicationNotFound
	}
	return nil
}