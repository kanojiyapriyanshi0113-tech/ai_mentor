package dto

import "time"

type RevenueMonthResponse struct {
	Month       string `json:"month"`
	AmountPaise int    `json:"amount_paise"`
}

type TeacherPayoutResponse struct {
	ID          string    `json:"id"`
	TeacherID   string    `json:"teacher_id"`
	AmountPaise int       `json:"amount_paise"`
	Note        string    `json:"note"`
	CreatedAt   time.Time `json:"created_at"`
}

type TeacherEarningsSummaryResponse struct {
	TeacherID          string                   `json:"teacher_id"`
	CommissionPercent  int                      `json:"commission_percent"`
	TotalStudents      int                      `json:"total_students"`
	TotalEarningsPaise int                      `json:"total_earnings_paise"`
	MonthlyEarningsPaise int                    `json:"monthly_earnings_paise"`
	PaidAmountPaise    int                      `json:"paid_amount_paise"`
	PendingPayoutPaise int                      `json:"pending_payout_paise"`
	RevenueHistory     []RevenueMonthResponse   `json:"revenue_history"`
	RecentPayouts      []TeacherPayoutResponse  `json:"recent_payouts"`
}

type TeacherStudentResponse struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Email       string    `json:"email"`
	BatchTitles []string  `json:"batch_titles"`
	LastActive  time.Time `json:"last_active"`
}

type SetCommissionRequest struct {
	CommissionPercent int `json:"commission_percent" binding:"required,min=0,max=100"`
}

type CreatePayoutRequest struct {
	AmountPaise int    `json:"amount_paise" binding:"required,min=1"`
	Note        string `json:"note"`
}
