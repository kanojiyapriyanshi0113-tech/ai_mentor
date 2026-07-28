package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

// TeacherPayoutRepository backs the Teacher Payout module: admin-created
// payout records that move from "pending" to "paid", plus the admin-facing
// (all teachers) and teacher-facing (own history) listing views.
type TeacherPayoutRepository interface {
	// Create inserts a new payout record with status "pending".
	Create(ctx context.Context, p *entity.TeacherPayoutRecord) error

	// GetByID fetches a single payout record by id.
	GetByID(ctx context.Context, id uuid.UUID) (*entity.TeacherPayoutRecord, error)

	// MarkPaid transitions a "pending" payout to "paid", stamping paid_by
	// and paid_at, and in the same transaction marks that teacher's
	// currently-payable earnings ledger rows as paid, linked to this
	// payout. Returns apperror.ErrPayoutNotFound if the id does not exist,
	// or apperror.ErrPayoutAlreadyPaid if it is not in "pending" status.
	MarkPaid(ctx context.Context, id uuid.UUID, paidBy uuid.UUID) (*entity.TeacherPayoutRecord, error)

	// ListAll returns payout records across all teachers (View Payouts),
	// optionally filtered by status ("" for all) and teacher, newest first.
	ListAll(ctx context.Context, status string, teacherID *uuid.UUID, limit, offset int) ([]entity.TeacherPayoutRecord, error)

	// ListByTeacher returns one teacher's own payout history, newest first.
	ListByTeacher(ctx context.Context, teacherID uuid.UUID, limit, offset int) ([]entity.TeacherPayoutRecord, error)
}
