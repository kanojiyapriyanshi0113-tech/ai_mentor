package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

// EarningsUsecase drives the teacher earnings & payouts modules: the
// teacher-facing summary/history/payout-history views, and the admin
// actions that set commission rates and record payouts.
type EarningsUsecase interface {
	GetSummary(ctx context.Context, teacherID string) (*entity.TeacherEarningsSummary, error)
	ListPayouts(ctx context.Context, teacherID string, limit int) ([]entity.TeacherPayout, error)
	ListStudents(ctx context.Context, teacherID string) ([]entity.TeacherStudent, error)
	SetCommissionPercent(ctx context.Context, teacherID string, percent int) error
	CreatePayout(ctx context.Context, teacherID string, amountPaise int, note string, paidBy string) (*entity.TeacherPayout, error)
}

type earningsUsecase struct {
	repo repository.EarningsRepository
}

func NewEarningsUsecase(repo repository.EarningsRepository) EarningsUsecase {
	return &earningsUsecase{repo: repo}
}

func (uc *earningsUsecase) GetSummary(ctx context.Context, teacherID string) (*entity.TeacherEarningsSummary, error) {
	tid, err := uuid.Parse(teacherID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}

	commission, err := uc.repo.GetCommissionPercent(ctx, tid)
	if err != nil {
		return nil, fmt.Errorf("get commission percent: %w", err)
	}
	totalStudents, err := uc.repo.CountTeacherStudents(ctx, tid)
	if err != nil {
		return nil, fmt.Errorf("count teacher students: %w", err)
	}
	totalRevenue, err := uc.repo.SumStudentPayments(ctx, tid, "")
	if err != nil {
		return nil, fmt.Errorf("sum all-time student payments: %w", err)
	}
	currentMonth, err := uc.repo.SumStudentPayments(ctx, tid, currentMonthKey())
	if err != nil {
		return nil, fmt.Errorf("sum current month student payments: %w", err)
	}
	history, err := uc.repo.RevenueHistory(ctx, tid, 6)
	if err != nil {
		return nil, fmt.Errorf("revenue history: %w", err)
	}
	paidOut, err := uc.repo.SumPaidOut(ctx, tid)
	if err != nil {
		return nil, fmt.Errorf("sum paid out: %w", err)
	}
	recentPayouts, err := uc.repo.ListPayouts(ctx, tid, 5)
	if err != nil {
		return nil, fmt.Errorf("list recent payouts: %w", err)
	}

	totalEarnings := applyCommission(totalRevenue, commission)
	monthlyEarnings := applyCommission(currentMonth, commission)
	pending := totalEarnings - paidOut
	if pending < 0 {
		pending = 0
	}

	return &entity.TeacherEarningsSummary{
		TeacherID:          teacherID,
		CommissionPercent:  commission,
		TotalStudents:      totalStudents,
		TotalEarningsPaise: totalEarnings,
		MonthlyEarnings:    monthlyEarnings,
		PaidAmountPaise:    paidOut,
		PendingPayoutPaise: pending,
		RevenueHistory:     history,
		RecentPayouts:      recentPayouts,
	}, nil
}

func (uc *earningsUsecase) ListPayouts(ctx context.Context, teacherID string, limit int) ([]entity.TeacherPayout, error) {
	tid, err := uuid.Parse(teacherID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return uc.repo.ListPayouts(ctx, tid, limit)
}

func (uc *earningsUsecase) ListStudents(ctx context.Context, teacherID string) ([]entity.TeacherStudent, error) {
	tid, err := uuid.Parse(teacherID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	return uc.repo.ListStudents(ctx, tid)
}

func (uc *earningsUsecase) SetCommissionPercent(ctx context.Context, teacherID string, percent int) error {
	tid, err := uuid.Parse(teacherID)
	if err != nil {
		return apperror.ErrInvalidInput
	}
	if percent < 0 || percent > 100 {
		return apperror.ErrInvalidCommissionPercent
	}
	return uc.repo.SetCommissionPercent(ctx, tid, percent)
}

func (uc *earningsUsecase) CreatePayout(ctx context.Context, teacherID string, amountPaise int, note string, paidBy string) (*entity.TeacherPayout, error) {
	if _, err := uuid.Parse(teacherID); err != nil {
		return nil, apperror.ErrInvalidInput
	}
	adminID, err := uuid.Parse(paidBy)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	if amountPaise <= 0 {
		return nil, apperror.ErrInvalidPayoutAmount
	}

	payout := &entity.TeacherPayout{
		TeacherID:   teacherID,
		AmountPaise: amountPaise,
		Note:        note,
		CreatedAt:   timeNow(),
	}
	if err := uc.repo.CreatePayout(ctx, payout, adminID); err != nil {
		return nil, fmt.Errorf("create payout: %w", err)
	}
	return payout, nil
}

func applyCommission(amountPaise, commissionPercent int) int {
	return (amountPaise * commissionPercent) / 100
}
