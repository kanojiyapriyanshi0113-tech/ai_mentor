package entity

import (
	"time"

	"github.com/google/uuid"
)

// TeacherPayoutStatus is the lifecycle state of a Teacher Payout module
// record. A payout starts "pending" when an admin creates it and moves to
// "paid" once the admin confirms the transfer via Mark Paid.
type TeacherPayoutStatus string

const (
	TeacherPayoutStatusPending TeacherPayoutStatus = "pending"
	TeacherPayoutStatusPaid    TeacherPayoutStatus = "paid"
)

// TeacherPayoutRecord is a full payout record for the Teacher Payout module.
// It is backed by the same teacher_payouts table used by the Earnings
// module's entity.TeacherPayout, but carries the pending -> paid lifecycle
// (status, created_by, paid_by, paid_at) needed for Admin Create Payout /
// Mark Paid / View Payouts / Teacher Payout History.
type TeacherPayoutRecord struct {
	ID          uuid.UUID
	TeacherID   uuid.UUID
	AmountPaise int
	Note        string
	Status      TeacherPayoutStatus
	CreatedBy   uuid.UUID
	PaidBy      *uuid.UUID
	PaidAt      *time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
