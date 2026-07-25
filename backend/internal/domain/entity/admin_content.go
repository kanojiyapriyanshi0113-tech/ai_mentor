package entity

import "time"

// Coupon represents a discount coupon that can be applied at checkout.
type Coupon struct {
    ID                  string
    Code                string
    DiscountPercent     int
    DiscountAmountPaise int
    MaxUses             int
    UsedCount           int
    ValidFrom           time.Time
    ValidUntil          time.Time
    IsActive            bool
    CreatedAt           time.Time
    UpdatedAt           time.Time
}

// Payment represents a single payment transaction made by a user.
type Payment struct {
    ID             string
    UserID         string
    SubscriptionID string
    AmountPaise    int
    Status         string
    PaymentMethod  string
    TransactionRef string
    CreatedAt      time.Time
    RefundedAt     *time.Time
}

// Banner represents a promotional banner shown in the app.
type Banner struct {
    ID           string
    Title        string
    ImageURL     string
    LinkURL      string
    DisplayOrder int
    IsActive     bool
    CreatedAt    time.Time
    UpdatedAt    time.Time
}

// AppSetting is a single key-value application setting (notifications, app config, etc).
type AppSetting struct {
    Key       string
    Value     string
    UpdatedAt time.Time
}

// AdminDashboardStats is the aggregate view for the admin dashboard.
type AdminDashboardStats struct {
    TotalStudents       int
    TotalTeachers       int
    TotalRevenuePaise   int64
    ActiveSubscriptions int
    ActiveBatches       int
    UpcomingLiveClasses int
    AIUsageToday        int
}

// TeacherAccount is the admin-facing view of a teacher user.
type TeacherAccount struct {
    ID          string
    Name        string
    Email       string
    IsApproved  bool
    IsSuspended bool
    CreatedAt   time.Time
}

// StudentAccount is the admin-facing view of a student user.
type StudentAccount struct {
    ID        string
    Name      string
    Email     string
    IsBlocked bool
    Premium   bool
    CreatedAt time.Time
}

// RevenueReport aggregates payment activity.
type RevenueReport struct {
    TotalRevenuePaise int64
    TotalPayments     int
    RefundedPaise     int64
}

// StudentsReport aggregates student activity.
type StudentsReport struct {
    TotalStudents   int
    NewStudents30d  int
    ActiveTrials    int
    PremiumStudents int
}

// CoursesReport aggregates content volume.
type CoursesReport struct {
    TotalBatches   int
    TotalSubjects  int
    TotalChapters  int
    TotalLectures  int
    TotalMockTests int
}
