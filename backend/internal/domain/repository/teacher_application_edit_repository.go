package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

// TeacherApplicationEditRepository covers the applicant-editable side of a
// teacher application (update while pending/changes-requested, and
// withdrawing it) plus an admin search/paginate listing. Kept separate from
// TeacherApplicationRepository so the existing interface and its callers
// are untouched.
type TeacherApplicationEditRepository interface {
	// Update overwrites the editable fields of an application. It only
	// applies when the application belongs to userID and is still in an
	// editable state (pending or changes_requested); otherwise it returns
	// apperror.ErrTeacherApplicationNotEditable.
	Update(ctx context.Context, a *entity.TeacherApplication, userID uuid.UUID) error

	// Cancel withdraws the applicant's own application. Only applies while
	// the application is pending or changes_requested.
	Cancel(ctx context.Context, id uuid.UUID, userID uuid.UUID) error

	// SearchList is List with an added free-text search (name/email/phone)
	// and a total count for pagination.
	SearchList(ctx context.Context, status string, search string, limit, offset int) ([]entity.TeacherApplication, int, error)
}

// TeacherApplicationFullRepository is the combined view a management
// usecase depends on; the existing postgres repository satisfies both
// halves once the new methods are added alongside it.
type TeacherApplicationFullRepository interface {
	TeacherApplicationRepository
	TeacherApplicationEditRepository
}
