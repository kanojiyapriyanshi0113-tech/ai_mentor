package usecase

import (
    "context"
    "fmt"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/domain/repository"
)

// StudentManagementUsecase drives the admin Student Management screen:
// a searchable, paginated student list, viewing a single student, and
// block/unblock/delete actions on a student account.
type StudentManagementUsecase interface {
    ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, int, error)
    GetStudent(ctx context.Context, id string) (*entity.StudentAccount, error)
    Block(ctx context.Context, id string) error
    Unblock(ctx context.Context, id string) error
    Delete(ctx context.Context, id string) error
}

type studentManagementUsecase struct {
    repo repository.StudentManagementFullRepository
}

func NewStudentManagementUsecase(repo repository.StudentManagementFullRepository) StudentManagementUsecase {
    return &studentManagementUsecase{repo: repo}
}

func (uc *studentManagementUsecase) ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, int, error) {
    if limit <= 0 || limit > 100 {
        limit = 20
    }
    if offset < 0 {
        offset = 0
    }
    total, err := uc.repo.CountStudents(ctx, search)
    if err != nil {
        return nil, 0, fmt.Errorf("count students: %w", err)
    }
    students, err := uc.repo.ListStudents(ctx, search, limit, offset)
    if err != nil {
        return nil, 0, fmt.Errorf("list students: %w", err)
    }
    return students, total, nil
}

func (uc *studentManagementUsecase) GetStudent(ctx context.Context, id string) (*entity.StudentAccount, error) {
    uid, err := uuid.Parse(id)
    if err != nil {
        return nil, apperror.ErrInvalidInput
    }
    return uc.repo.FindStudentByID(ctx, uid)
}

func (uc *studentManagementUsecase) Block(ctx context.Context, id string) error {
    return uc.setBlocked(ctx, id, true)
}

func (uc *studentManagementUsecase) Unblock(ctx context.Context, id string) error {
    return uc.setBlocked(ctx, id, false)
}

func (uc *studentManagementUsecase) setBlocked(ctx context.Context, id string, block bool) error {
    uid, err := uuid.Parse(id)
    if err != nil {
        return apperror.ErrInvalidInput
    }
    if err := uc.repo.BlockStudent(ctx, uid, block); err != nil {
        return fmt.Errorf("set student blocked state: %w", err)
    }
    return nil
}

func (uc *studentManagementUsecase) Delete(ctx context.Context, id string) error {
    uid, err := uuid.Parse(id)
    if err != nil {
        return apperror.ErrInvalidInput
    }
    if err := uc.repo.DeleteStudent(ctx, uid); err != nil {
        return fmt.Errorf("delete student: %w", err)
    }
    return nil
}
