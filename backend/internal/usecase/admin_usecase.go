package usecase

import (
    "context"
    "fmt"
    "time"

    "github.com/google/uuid"
    "golang.org/x/crypto/bcrypt"

    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/domain/repository"
)

type AddTeacherInput struct {
    Name     string
    Email    string
    Password string
}

type EditTeacherInput struct {
    ID    string
    Name  string
    Email string
}

type CreatePlanInput struct {
    Code         string
    Name         string
    PricePaise   int
    DurationDays int
    IsTrial      bool
}

type UpdatePlanInput struct {
    ID           int
    Name         string
    PricePaise   int
    DurationDays int
    IsTrial      bool
}

type CreateCouponInput struct {
    Code                string
    DiscountPercent     int
    DiscountAmountPaise int
    MaxUses             int
    ValidFrom           time.Time
    ValidUntil          time.Time
}

type UpdateCouponInput struct {
    ID                  string
    DiscountPercent     int
    DiscountAmountPaise int
    MaxUses             int
    ValidFrom           time.Time
    ValidUntil          time.Time
    IsActive            bool
}

type CreateBannerInput struct {
    Title        string
    ImageURL     string
    LinkURL      string
    DisplayOrder int
}

type UpdateBannerInput struct {
    ID           string
    Title        string
    ImageURL     string
    LinkURL      string
    DisplayOrder int
    IsActive     bool
}

type AdminUsecase interface {
    GetDashboard(ctx context.Context) (*entity.AdminDashboardStats, error)

    AddTeacher(ctx context.Context, in AddTeacherInput) (*entity.TeacherAccount, error)
    ApproveTeacher(ctx context.Context, id string) error
    EditTeacher(ctx context.Context, in EditTeacherInput) error
    SuspendTeacher(ctx context.Context, id string, suspend bool) error
    DeleteTeacher(ctx context.Context, id string) error
    ListTeachers(ctx context.Context) ([]entity.TeacherAccount, error)

    ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, error)
    BlockStudent(ctx context.Context, id string, block bool) error
    DeleteStudent(ctx context.Context, id string) error

    CreatePlan(ctx context.Context, in CreatePlanInput) (*entity.Plan, error)
    UpdatePlan(ctx context.Context, in UpdatePlanInput) error
    SetPlanActive(ctx context.Context, id int, active bool) error

    CreateCoupon(ctx context.Context, in CreateCouponInput) (*entity.Coupon, error)
    UpdateCoupon(ctx context.Context, in UpdateCouponInput) error
    DeleteCoupon(ctx context.Context, id string) error
    ListCoupons(ctx context.Context) ([]entity.Coupon, error)

    ListPayments(ctx context.Context, limit, offset int) ([]entity.Payment, error)
    RefundPayment(ctx context.Context, id string) error

    GetRevenueReport(ctx context.Context) (*entity.RevenueReport, error)
    GetStudentsReport(ctx context.Context) (*entity.StudentsReport, error)
    GetCoursesReport(ctx context.Context) (*entity.CoursesReport, error)

    GetSettings(ctx context.Context) ([]entity.AppSetting, error)
    SetSetting(ctx context.Context, key, value string) error

    CreateBanner(ctx context.Context, in CreateBannerInput) (*entity.Banner, error)
    UpdateBanner(ctx context.Context, in UpdateBannerInput) error
    DeleteBanner(ctx context.Context, id string) error
    ListBanners(ctx context.Context) ([]entity.Banner, error)
}

type adminUsecase struct {
    adminRepo repository.AdminRepository
}

func NewAdminUsecase(adminRepo repository.AdminRepository) AdminUsecase {
    return &adminUsecase{adminRepo: adminRepo}
}

func (uc *adminUsecase) GetDashboard(ctx context.Context) (*entity.AdminDashboardStats, error) {
    stats, err := uc.adminRepo.GetDashboardStats(ctx)
    if err != nil {
        return nil, fmt.Errorf("get dashboard stats: %w", err)
    }
    return stats, nil
}

func (uc *adminUsecase) AddTeacher(ctx context.Context, in AddTeacherInput) (*entity.TeacherAccount, error) {
    hash, err := bcrypt.GenerateFromPassword([]byte(in.Password), bcrypt.DefaultCost)
    if err != nil {
        return nil, fmt.Errorf("hash password: %w", err)
    }
    t, err := uc.adminRepo.AddTeacher(ctx, in.Name, in.Email, string(hash))
    if err != nil {
        return nil, fmt.Errorf("add teacher: %w", err)
    }
    return t, nil
}

func (uc *adminUsecase) ApproveTeacher(ctx context.Context, id string) error {
    teacherID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid teacher id: %w", err)
    }
    return uc.adminRepo.ApproveTeacher(ctx, teacherID)
}

func (uc *adminUsecase) EditTeacher(ctx context.Context, in EditTeacherInput) error {
    teacherID, err := uuid.Parse(in.ID)
    if err != nil {
        return fmt.Errorf("invalid teacher id: %w", err)
    }
    return uc.adminRepo.EditTeacher(ctx, teacherID, in.Name, in.Email)
}

func (uc *adminUsecase) SuspendTeacher(ctx context.Context, id string, suspend bool) error {
    teacherID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid teacher id: %w", err)
    }
    return uc.adminRepo.SuspendTeacher(ctx, teacherID, suspend)
}

func (uc *adminUsecase) DeleteTeacher(ctx context.Context, id string) error {
    teacherID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid teacher id: %w", err)
    }
    return uc.adminRepo.DeleteTeacher(ctx, teacherID)
}

func (uc *adminUsecase) ListTeachers(ctx context.Context) ([]entity.TeacherAccount, error) {
    return uc.adminRepo.ListTeachers(ctx)
}

func (uc *adminUsecase) ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, error) {
    if limit <= 0 {
        limit = 20
    }
    return uc.adminRepo.ListStudents(ctx, search, limit, offset)
}

func (uc *adminUsecase) BlockStudent(ctx context.Context, id string, block bool) error {
    studentID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid student id: %w", err)
    }
    return uc.adminRepo.BlockStudent(ctx, studentID, block)
}

func (uc *adminUsecase) DeleteStudent(ctx context.Context, id string) error {
    studentID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid student id: %w", err)
    }
    return uc.adminRepo.DeleteStudent(ctx, studentID)
}

func (uc *adminUsecase) CreatePlan(ctx context.Context, in CreatePlanInput) (*entity.Plan, error) {
    p := &entity.Plan{
        Code: in.Code, Name: in.Name, PricePaise: in.PricePaise,
        DurationDays: in.DurationDays, IsTrial: in.IsTrial, IsActive: true,
    }
    if err := uc.adminRepo.CreatePlan(ctx, p); err != nil {
        return nil, fmt.Errorf("create plan: %w", err)
    }
    return p, nil
}

func (uc *adminUsecase) UpdatePlan(ctx context.Context, in UpdatePlanInput) error {
    p := &entity.Plan{ID: in.ID, Name: in.Name, PricePaise: in.PricePaise, DurationDays: in.DurationDays, IsTrial: in.IsTrial}
    return uc.adminRepo.UpdatePlan(ctx, p)
}

func (uc *adminUsecase) SetPlanActive(ctx context.Context, id int, active bool) error {
    return uc.adminRepo.SetPlanActive(ctx, id, active)
}

func (uc *adminUsecase) CreateCoupon(ctx context.Context, in CreateCouponInput) (*entity.Coupon, error) {
    c := &entity.Coupon{
        Code: in.Code, DiscountPercent: in.DiscountPercent, DiscountAmountPaise: in.DiscountAmountPaise,
        MaxUses: in.MaxUses, ValidFrom: in.ValidFrom, ValidUntil: in.ValidUntil,
    }
    if err := uc.adminRepo.CreateCoupon(ctx, c); err != nil {
        return nil, fmt.Errorf("create coupon: %w", err)
    }
    return c, nil
}

func (uc *adminUsecase) UpdateCoupon(ctx context.Context, in UpdateCouponInput) error {
    c := &entity.Coupon{
        ID: in.ID, DiscountPercent: in.DiscountPercent, DiscountAmountPaise: in.DiscountAmountPaise,
        MaxUses: in.MaxUses, ValidFrom: in.ValidFrom, ValidUntil: in.ValidUntil, IsActive: in.IsActive,
    }
    return uc.adminRepo.UpdateCoupon(ctx, c)
}

func (uc *adminUsecase) DeleteCoupon(ctx context.Context, id string) error {
    couponID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid coupon id: %w", err)
    }
    return uc.adminRepo.DeleteCoupon(ctx, couponID)
}

func (uc *adminUsecase) ListCoupons(ctx context.Context) ([]entity.Coupon, error) {
    return uc.adminRepo.ListCoupons(ctx)
}

func (uc *adminUsecase) ListPayments(ctx context.Context, limit, offset int) ([]entity.Payment, error) {
    if limit <= 0 {
        limit = 20
    }
    return uc.adminRepo.ListPayments(ctx, limit, offset)
}

func (uc *adminUsecase) RefundPayment(ctx context.Context, id string) error {
    paymentID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid payment id: %w", err)
    }
    return uc.adminRepo.RefundPayment(ctx, paymentID)
}

func (uc *adminUsecase) GetRevenueReport(ctx context.Context) (*entity.RevenueReport, error) {
    return uc.adminRepo.GetRevenueReport(ctx)
}

func (uc *adminUsecase) GetStudentsReport(ctx context.Context) (*entity.StudentsReport, error) {
    return uc.adminRepo.GetStudentsReport(ctx)
}

func (uc *adminUsecase) GetCoursesReport(ctx context.Context) (*entity.CoursesReport, error) {
    return uc.adminRepo.GetCoursesReport(ctx)
}

func (uc *adminUsecase) GetSettings(ctx context.Context) ([]entity.AppSetting, error) {
    return uc.adminRepo.ListSettings(ctx)
}

func (uc *adminUsecase) SetSetting(ctx context.Context, key, value string) error {
    return uc.adminRepo.SetSetting(ctx, key, value)
}

func (uc *adminUsecase) CreateBanner(ctx context.Context, in CreateBannerInput) (*entity.Banner, error) {
    b := &entity.Banner{Title: in.Title, ImageURL: in.ImageURL, LinkURL: in.LinkURL, DisplayOrder: in.DisplayOrder}
    if err := uc.adminRepo.CreateBanner(ctx, b); err != nil {
        return nil, fmt.Errorf("create banner: %w", err)
    }
    return b, nil
}

func (uc *adminUsecase) UpdateBanner(ctx context.Context, in UpdateBannerInput) error {
    b := &entity.Banner{ID: in.ID, Title: in.Title, ImageURL: in.ImageURL, LinkURL: in.LinkURL, DisplayOrder: in.DisplayOrder, IsActive: in.IsActive}
    return uc.adminRepo.UpdateBanner(ctx, b)
}

func (uc *adminUsecase) DeleteBanner(ctx context.Context, id string) error {
    bannerID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid banner id: %w", err)
    }
    return uc.adminRepo.DeleteBanner(ctx, bannerID)
}

func (uc *adminUsecase) ListBanners(ctx context.Context) ([]entity.Banner, error) {
    return uc.adminRepo.ListBanners(ctx)
}
