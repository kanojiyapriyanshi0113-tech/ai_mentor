package entity

import (
	"time"

	"github.com/google/uuid"
)

// EarningSource identifies what generated a teacher earning entry.
type EarningSource string

const (
	EarningSourceSubscription EarningSource = "subscription"
	EarningSourceCourseSale   EarningSource = "course_sale"
	EarningSourceBonus        EarningSource = "bonus"
	EarningSourceAdjustment   EarningSource = "adjustment"
)

// EarningStatus is the lifecycle state of a single earning ledger entry.
type EarningStatus string

const (
	EarningPending  EarningStatus = "pending"
	EarningPayable  EarningStatus = "payable"
	EarningPaid     EarningStatus = "paid"
	EarningReversed EarningStatus = "reversed"
)

// TeacherEarning is one attributed earning transaction for a teacher,
// distinct from TeacherPayout (money actually paid out) and the
// commission-percent rate stored per teacher. Summing unpaid, non-reversed
// rows for a teacher gives the pending payout balance.
type TeacherEarning struct {
	ID                uuid.UUID
	TeacherID         uuid.UUID
	StudentID         *uuid.UUID
	PaymentID         *uuid.UUID
	PayoutID          *uuid.UUID
	Source            EarningSource
	GrossAmountPaise  int
	CommissionPercent int
	EarnedAmountPaise int
	Status            EarningStatus
	EarnedAt          time.Time
	CreatedAt         time.Time
	UpdatedAt         time.Time
	DeletedAt         *time.Time
}
