package dto

import "time"

// CreateTeacherPayoutRequest is the body for Admin Create Payout:
// POST /admin/teachers/:id/teacher-payouts
type CreateTeacherPayoutRequest struct {
	AmountPaise int    `json:"amount_paise" binding:"required,min=1"`
	Note        string `json:"note"`
}

// TeacherPayoutRecordResponse is the payout record shape returned by the
// Teacher Payout module (create, mark paid, view payouts, payout history).
type TeacherPayoutRecordResponse struct {
	ID          string     `json:"id"`
	TeacherID   string     `json:"teacher_id"`
	AmountPaise int        `json:"amount_paise"`
	Note        string     `json:"note"`
	Status      string     `json:"status"`
	CreatedBy   string     `json:"created_by,omitempty"`
	PaidBy      string     `json:"paid_by,omitempty"`
	PaidAt      *time.Time `json:"paid_at,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}
