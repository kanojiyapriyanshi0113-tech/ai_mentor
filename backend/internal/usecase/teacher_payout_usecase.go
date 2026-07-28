package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

const teacherPayoutDefaultLimit = 20
const teacherPayoutMaxLimit = 100

// TeacherPayoutUsecase drives the Teacher Payout module: admin creation of
// payout records, marking them paid, the admin-facing global payout list,
// and the teacher-facing payout history.
type TeacherPayoutUsecase interface {
	// CreatePayout records a new pending payout for a teacher. (Admin Create Payout)
	CreatePayout(ctx context.Context, teacherID string, amountPaise int, note string, createdBy string) (*entity.TeacherPayoutRecord, error)

	// MarkPaid confirms a pending payout as paid. (Mark Paid)
	MarkPaid(ctx context.Context, payoutID string, paidBy string) (*entity.TeacherPayoutRecord, error)

	// ListPayouts lists payout records across all teachers, optionally
	// filtered by status and/or teacher. (View Payouts)
	ListPayouts(ctx context.Context, status string, teacherID string, limit, offset int) ([]entity.TeacherPayoutRecord, error)

	// GetPayoutHistory lists a single teacher's own payout history. (Teacher Payout History)
	GetPayoutHistory(ctx context.Context, teacherID string, limit, offset int) ([]entity.TeacherPayoutRecord, error)
}

type teacherPayoutUsecase struct {
	repo repository.TeacherPayoutRepository
}

func NewTeacherPayoutUsecase(repo repository.TeacherPayoutRepository) TeacherPayoutUsecase {
	return &teacherPayoutUsecase{repo: repo}
}

func normalizeTeacherPayoutPage(limit, offset int) (int, int) {
	if limit <= 0 || limit > teacherPayoutMaxLimit {
		limit = teacherPayoutDefaultLimit
	}
	if offset < 0 {
		offset = 0
	}
	return limit, offset
}

func (uc *teacherPayoutUsecase) CreatePayout(ctx context.Context, teacherID string, amountPaise int, note string, createdBy string) (*entity.TeacherPayoutRecord, error) {
	tid, err := uuid.Parse(teacherID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	adminID, err := uuid.Parse(createdBy)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	if amountPaise <= 0 {
		return nil, apperror.ErrInvalidPayoutAmount
	}

	payout := &entity.TeacherPayoutRecord{
		TeacherID:   tid,
		AmountPaise: amountPaise,
		Note:        note,
		Status:      entity.TeacherPayoutStatusPending,
		CreatedBy:   adminID,
	}
	if err := uc.repo.Create(ctx, payout); err != nil {
		return nil, fmt.Errorf("create teacher payout: %w", err)
	}
	return payout, nil
}

func (uc *teacherPayoutUsecase) MarkPaid(ctx context.Context, payoutID string, paidBy string) (*entity.TeacherPayoutRecord, error) {
	pid, err := uuid.Parse(payoutID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	adminID, err := uuid.Parse(paidBy)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}

	payout, err := uc.repo.MarkPaid(ctx, pid, adminID)
	if err != nil {
		return nil, err
	}
	return payout, nil
}

func (uc *teacherPayoutUsecase) ListPayouts(ctx context.Context, status string, teacherID string, limit, offset int) ([]entity.TeacherPayoutRecord, error) {
	if status != "" && status != string(entity.TeacherPayoutStatusPending) && status != string(entity.TeacherPayoutStatusPaid) {
		return nil, apperror.ErrInvalidInput
	}

	var tidPtr *uuid.UUID
	if teacherID != "" {
		tid, err := uuid.Parse(teacherID)
		if err != nil {
			return nil, apperror.ErrInvalidInput
		}
		tidPtr = &tid
	}

	limit, offset = normalizeTeacherPayoutPage(limit, offset)
	return uc.repo.ListAll(ctx, status, tidPtr, limit, offset)
}

func (uc *teacherPayoutUsecase) GetPayoutHistory(ctx context.Context, teacherID string, limit, offset int) ([]entity.TeacherPayoutRecord, error) {
	tid, err := uuid.Parse(teacherID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	limit, offset = normalizeTeacherPayoutPage(limit, offset)
	return uc.repo.ListByTeacher(ctx, tid, limit, offset)
}
