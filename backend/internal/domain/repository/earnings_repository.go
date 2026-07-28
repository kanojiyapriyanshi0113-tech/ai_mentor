package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

// EarningsRepository provides the revenue-share earnings view for teachers
// and the admin actions that manage it (commission %, payouts).
type EarningsRepository interface {
	GetCommissionPercent(ctx context.Context, teacherID uuid.UUID) (int, error)
	SetCommissionPercent(ctx context.Context, teacherID uuid.UUID, percent int) error

	// CountTeacherStudents returns the number of distinct students who have
	// engaged with the given teacher's batches.
	CountTeacherStudents(ctx context.Context, teacherID uuid.UUID) (int, error)

	// SumStudentPayments returns total successful-payment revenue (in paise)
	// attributed to the teacher's students, optionally restricted to the
	// given calendar month ("" for all-time). monthKey format: "2026-07".
	SumStudentPayments(ctx context.Context, teacherID uuid.UUID, monthKey string) (int, error)

	// RevenueHistory returns the last n months of attributed revenue.
	RevenueHistory(ctx context.Context, teacherID uuid.UUID, months int) ([]entity.RevenueMonth, error)

	SumPaidOut(ctx context.Context, teacherID uuid.UUID) (int, error)
	ListPayouts(ctx context.Context, teacherID uuid.UUID, limit int) ([]entity.TeacherPayout, error)
	CreatePayout(ctx context.Context, p *entity.TeacherPayout, paidBy uuid.UUID) error

	ListStudents(ctx context.Context, teacherID uuid.UUID) ([]entity.TeacherStudent, error)
}