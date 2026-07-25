package repository

import (
    "context"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

// AdminRepository provides platform-management persistence for the admin
// role: users (teacher/student), plans, coupons, payments, reports,
// settings, and banners. It never touches course content tables directly.
type AdminRepository interface {
    GetDashboardStats(ctx context.Context) (*entity.AdminDashboardStats, error)

    AddTeacher(ctx context.Context, name, email, passwordHash string) (*entity.TeacherAccount, error)
    ApproveTeacher(ctx context.Context, id uuid.UUID) error
    EditTeacher(ctx context.Context, id uuid.UUID, name, email string) error
    SuspendTeacher(ctx context.Context, id uuid.UUID, suspend bool) error
    DeleteTeacher(ctx context.Context, id uuid.UUID) error
    ListTeachers(ctx context.Context) ([]entity.TeacherAccount, error)

    ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, error)
    BlockStudent(ctx context.Context, id uuid.UUID, block bool) error
    DeleteStudent(ctx context.Context, id uuid.UUID) error

    CreatePlan(ctx context.Context, p *entity.Plan) error
    UpdatePlan(ctx context.Context, p *entity.Plan) error
    SetPlanActive(ctx context.Context, id int, active bool) error

    CreateCoupon(ctx context.Context, c *entity.Coupon) error
    UpdateCoupon(ctx context.Context, c *entity.Coupon) error
    DeleteCoupon(ctx context.Context, id uuid.UUID) error
    ListCoupons(ctx context.Context) ([]entity.Coupon, error)

    ListPayments(ctx context.Context, limit, offset int) ([]entity.Payment, error)
    RefundPayment(ctx context.Context, id uuid.UUID) error

    GetRevenueReport(ctx context.Context) (*entity.RevenueReport, error)
    GetStudentsReport(ctx context.Context) (*entity.StudentsReport, error)
    GetCoursesReport(ctx context.Context) (*entity.CoursesReport, error)

    GetSetting(ctx context.Context, key string) (string, error)
    SetSetting(ctx context.Context, key, value string) error
    ListSettings(ctx context.Context) ([]entity.AppSetting, error)

    CreateBanner(ctx context.Context, b *entity.Banner) error
    UpdateBanner(ctx context.Context, b *entity.Banner) error
    DeleteBanner(ctx context.Context, id uuid.UUID) error
    ListBanners(ctx context.Context) ([]entity.Banner, error)
}
