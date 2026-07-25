package dto

import "time"

type AddTeacherRequest struct {
    Name     string `json:"name" binding:"required"`
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=8"`
}

type EditTeacherRequest struct {
    Name  string `json:"name" binding:"required"`
    Email string `json:"email" binding:"required,email"`
}

type SuspendTeacherRequest struct {
    Suspend bool `json:"suspend"`
}

type BlockStudentRequest struct {
    Block bool `json:"block"`
}

type CreatePlanRequest struct {
    Code         string `json:"code" binding:"required"`
    Name         string `json:"name" binding:"required"`
    PricePaise   int    `json:"price_paise"`
    DurationDays int    `json:"duration_days" binding:"required"`
    IsTrial      bool   `json:"is_trial"`
}

type UpdatePlanRequest struct {
    Name         string `json:"name" binding:"required"`
    PricePaise   int    `json:"price_paise"`
    DurationDays int    `json:"duration_days" binding:"required"`
    IsTrial      bool   `json:"is_trial"`
}

type CreateCouponRequest struct {
    Code                string    `json:"code" binding:"required"`
    DiscountPercent     int       `json:"discount_percent"`
    DiscountAmountPaise int       `json:"discount_amount_paise"`
    MaxUses             int       `json:"max_uses"`
    ValidFrom           time.Time `json:"valid_from"`
    ValidUntil          time.Time `json:"valid_until" binding:"required"`
}

type UpdateCouponRequest struct {
    DiscountPercent     int       `json:"discount_percent"`
    DiscountAmountPaise int       `json:"discount_amount_paise"`
    MaxUses             int       `json:"max_uses"`
    ValidFrom           time.Time `json:"valid_from"`
    ValidUntil          time.Time `json:"valid_until" binding:"required"`
    IsActive            bool      `json:"is_active"`
}

type CreateBannerRequest struct {
    Title        string `json:"title" binding:"required"`
    ImageURL     string `json:"image_url" binding:"required"`
    LinkURL      string `json:"link_url"`
    DisplayOrder int    `json:"display_order"`
}

type UpdateBannerRequest struct {
    Title        string `json:"title" binding:"required"`
    ImageURL     string `json:"image_url" binding:"required"`
    LinkURL      string `json:"link_url"`
    DisplayOrder int    `json:"display_order"`
    IsActive     bool   `json:"is_active"`
}

type SetSettingRequest struct {
    Value string `json:"value"`
}

type AdminDashboardResponse struct {
    TotalStudents       int   `json:"total_students"`
    TotalTeachers       int   `json:"total_teachers"`
    TotalRevenuePaise   int64 `json:"total_revenue_paise"`
    ActiveSubscriptions int   `json:"active_subscriptions"`
    ActiveBatches       int   `json:"active_batches"`
    UpcomingLiveClasses int   `json:"upcoming_live_classes"`
    AIUsageToday        int   `json:"ai_usage_today"`
}

type TeacherAccountResponse struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Email       string    `json:"email"`
    IsApproved  bool      `json:"is_approved"`
    IsSuspended bool      `json:"is_suspended"`
    CreatedAt   time.Time `json:"created_at"`
}

type StudentAccountResponse struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    IsBlocked bool      `json:"is_blocked"`
    Premium   bool      `json:"premium"`
    CreatedAt time.Time `json:"created_at"`
}

type AdminPlanResponse struct {
    ID           int    `json:"id"`
    Code         string `json:"code"`
    Name         string `json:"name"`
    PricePaise   int    `json:"price_paise"`
    DurationDays int    `json:"duration_days"`
    IsTrial      bool   `json:"is_trial"`
    IsActive     bool   `json:"is_active"`
}

type CouponResponse struct {
    ID                  string    `json:"id"`
    Code                string    `json:"code"`
    DiscountPercent     int       `json:"discount_percent"`
    DiscountAmountPaise int       `json:"discount_amount_paise"`
    MaxUses             int       `json:"max_uses"`
    UsedCount           int       `json:"used_count"`
    ValidFrom           time.Time `json:"valid_from"`
    ValidUntil          time.Time `json:"valid_until"`
    IsActive            bool      `json:"is_active"`
}

type PaymentResponse struct {
    ID             string     `json:"id"`
    UserID         string     `json:"user_id"`
    SubscriptionID string     `json:"subscription_id,omitempty"`
    AmountPaise    int        `json:"amount_paise"`
    Status         string     `json:"status"`
    PaymentMethod  string     `json:"payment_method"`
    TransactionRef string     `json:"transaction_ref"`
    CreatedAt      time.Time  `json:"created_at"`
    RefundedAt     *time.Time `json:"refunded_at,omitempty"`
}

type RevenueReportResponse struct {
    TotalRevenuePaise int64 `json:"total_revenue_paise"`
    TotalPayments     int   `json:"total_payments"`
    RefundedPaise     int64 `json:"refunded_paise"`
}

type StudentsReportResponse struct {
    TotalStudents   int `json:"total_students"`
    NewStudents30d  int `json:"new_students_30d"`
    ActiveTrials    int `json:"active_trials"`
    PremiumStudents int `json:"premium_students"`
}

type CoursesReportResponse struct {
    TotalBatches   int `json:"total_batches"`
    TotalSubjects  int `json:"total_subjects"`
    TotalChapters  int `json:"total_chapters"`
    TotalLectures  int `json:"total_lectures"`
    TotalMockTests int `json:"total_mock_tests"`
}

type AppSettingResponse struct {
    Key   string `json:"key"`
    Value string `json:"value"`
}

type BannerResponse struct {
    ID           string `json:"id"`
    Title        string `json:"title"`
    ImageURL     string `json:"image_url"`
    LinkURL      string `json:"link_url"`
    DisplayOrder int    `json:"display_order"`
    IsActive     bool   `json:"is_active"`
}
