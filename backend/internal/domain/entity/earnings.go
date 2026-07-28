package entity

import "time"

// TeacherPayout is a single completed payout made to a teacher.
type TeacherPayout struct {
	ID          string
	TeacherID   string
	AmountPaise int
	Note        string
	CreatedAt   time.Time
}

// RevenueMonth is one point in a teacher's monthly revenue history.
type RevenueMonth struct {
	Month       string // "2026-07"
	AmountPaise int
}

// TeacherEarningsSummary is the aggregate earnings view for one teacher,
// computed under a simple revenue-share model: the commission percentage
// is applied to the subscription payments made by students who have
// engaged with that teacher's batches. This is an MVP attribution model
// intended to be replaced by per-course purchase tracking if the product
// introduces per-course pricing.
type TeacherEarningsSummary struct {
	TeacherID          string
	CommissionPercent  int
	TotalStudents      int
	TotalEarningsPaise int
	MonthlyEarnings    int
	PaidAmountPaise    int
	PendingPayoutPaise int
	RevenueHistory     []RevenueMonth
	RecentPayouts      []TeacherPayout
}