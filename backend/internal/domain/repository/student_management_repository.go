package repository

import (
    "context"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

// StudentRepository is the subset of student-account persistence that
// already exists on AdminRepository (list/search+paginate, block/unblock,
// delete). Declared again here, with identical signatures, so the Student
// Management usecase can depend on a small, focused interface instead of
// the full AdminRepository. The existing postgres AdminRepository
// implementation already satisfies this -- no changes needed there.
type StudentRepository interface {
    ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, error)
    BlockStudent(ctx context.Context, id uuid.UUID, block bool) error
    DeleteStudent(ctx context.Context, id uuid.UUID) error
}

// StudentManagementRepository covers what StudentRepository doesn't yet
// provide: a total count for pagination, and looking up a single student
// (View Student).
type StudentManagementRepository interface {
    // CountStudents returns the total number of students matching the same
    // search filter used by ListStudents (empty search = all students).
    CountStudents(ctx context.Context, search string) (int, error)

    // FindStudentByID returns the admin-facing view of a single student
    // account. Returns apperror.ErrStudentNotFound if id doesn't belong to
    // a role=student user.
    FindStudentByID(ctx context.Context, id uuid.UUID) (*entity.StudentAccount, error)
}

// StudentManagementFullRepository is the combined view the Student
// Management usecase depends on. The existing postgres AdminRepository
// implementation satisfies StudentRepository already; adding CountStudents
// and FindStudentByID onto the same struct (in its own file, within the
// postgres package) makes it satisfy this combined interface too.
type StudentManagementFullRepository interface {
    StudentRepository
    StudentManagementRepository
}
