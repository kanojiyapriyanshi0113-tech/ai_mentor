package entity

import (
	"time"

	"github.com/google/uuid"
)

// RefundStatus is the approval/processing state of a refund request.
type RefundStatus string

const (
	RefundPending   RefundStatus = "pending"
	RefundApproved  RefundStatus = "approved"
	RefundRejected  RefundStatus = "rejected"
	RefundProcessed RefundStatus = "processed"
)

// Refund is the request/approval ledger entry behind a Payment's
// "refunded" status — records why it was refunded, who approved it, and
// the gateway reference for the money movement.
type Refund struct {
	ID           uuid.UUID
	PaymentID    uuid.UUID
	UserID       uuid.UUID
	AmountPaise  int
	Reason       string
	Status       RefundStatus
	GatewayRef   string
	ProcessedBy  *uuid.UUID
	RequestedAt  time.Time
	ProcessedAt  *time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time
	DeletedAt    *time.Time
}
