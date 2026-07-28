package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

// TeacherApprovalRepository covers the pieces of the Teacher Approval module
// that aren't already served by TeacherApplicationRepository: a paginated
// pending-applications queue (with a total count for paging) and teacher
// account suspension. Kept separate so the existing
// TeacherApplicationRepository and its callers stay untouched.
type TeacherApprovalRepository interface {
	// ListPendingApplications returns applications with status "pending",
	// oldest first (so the queue is worked in submission order), alongside
	// the total number of pending applications for pagination.
	ListPendingApplications(ctx context.Context, limit, offset int) ([]entity.TeacherApplication, int, error)

	// FindTeacherByID returns the admin-facing view of a teacher account.
	// Returns apperror.ErrTeacherNotFound if id doesn't belong to a
	// role=teacher user.
	FindTeacherByID(ctx context.Context, id uuid.UUID) (*entity.TeacherAccount, error)

	// SetTeacherSuspension suspends (true) or reactivates (false) a
	// teacher account.
	SetTeacherSuspension(ctx context.Context, id uuid.UUID, suspend bool) error
}

// TeacherApprovalFullRepository is the combined view the Teacher Approval
// usecase depends on: existing application lookup/review methods plus the
// new pending-queue and suspension methods above. The existing postgres
// TeacherApplicationRepository implementation satisfies
// TeacherApplicationRepository already; adding the three methods above onto
// the same struct (in its own file, within the postgres package) makes it
// satisfy this combined interface too.
type TeacherApprovalFullRepository interface {
	TeacherApplicationRepository
	TeacherApprovalRepository
}
