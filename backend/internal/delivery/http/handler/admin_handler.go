package handler

import (
    "errors"
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"

    "ai-mentor-backend/internal/delivery/http/dto"
    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/usecase"
)

type AdminHandler struct {
    adminUC usecase.AdminUsecase
}

func NewAdminHandler(adminUC usecase.AdminUsecase) *AdminHandler {
    return &AdminHandler{adminUC: adminUC}
}

func toTeacherDTO(t entity.TeacherAccount) dto.TeacherAccountResponse {
    return dto.TeacherAccountResponse{
        ID: t.ID, Name: t.Name, Email: t.Email, IsApproved: t.IsApproved, IsSuspended: t.IsSuspended, CreatedAt: t.CreatedAt,
    }
}

func toStudentDTO(s entity.StudentAccount) dto.StudentAccountResponse {
    return dto.StudentAccountResponse{
        ID: s.ID, Name: s.Name, Email: s.Email, IsBlocked: s.IsBlocked, Premium: s.Premium, CreatedAt: s.CreatedAt,
    }
}

func toAdminPlanDTO(p entity.Plan) dto.AdminPlanResponse {
    return dto.AdminPlanResponse{
        ID: p.ID, Code: p.Code, Name: p.Name, PricePaise: p.PricePaise,
        DurationDays: p.DurationDays, IsTrial: p.IsTrial, IsActive: p.IsActive,
    }
}

func toCouponDTO(c entity.Coupon) dto.CouponResponse {
    return dto.CouponResponse{
        ID: c.ID, Code: c.Code, DiscountPercent: c.DiscountPercent, DiscountAmountPaise: c.DiscountAmountPaise,
        MaxUses: c.MaxUses, UsedCount: c.UsedCount, ValidFrom: c.ValidFrom, ValidUntil: c.ValidUntil, IsActive: c.IsActive,
    }
}

func toPaymentDTO(p entity.Payment) dto.PaymentResponse {
    return dto.PaymentResponse{
        ID: p.ID, UserID: p.UserID, SubscriptionID: p.SubscriptionID, AmountPaise: p.AmountPaise,
        Status: p.Status, PaymentMethod: p.PaymentMethod, TransactionRef: p.TransactionRef,
        CreatedAt: p.CreatedAt, RefundedAt: p.RefundedAt,
    }
}

func toBannerDTO(b entity.Banner) dto.BannerResponse {
    return dto.BannerResponse{
        ID: b.ID, Title: b.Title, ImageURL: b.ImageURL, LinkURL: b.LinkURL, DisplayOrder: b.DisplayOrder, IsActive: b.IsActive,
    }
}

func handleAdminError(c *gin.Context, err error) {
    switch {
    case errors.Is(err, apperror.ErrTeacherNotFound):
        response.Error(c, http.StatusNotFound, "TEACHER_NOT_FOUND", "Teacher not found")
    case errors.Is(err, apperror.ErrStudentNotFound):
        response.Error(c, http.StatusNotFound, "STUDENT_NOT_FOUND", "Student not found")
    case errors.Is(err, apperror.ErrEmailAlreadyExists):
        response.Error(c, http.StatusConflict, "EMAIL_EXISTS", "Email already in use")
    case errors.Is(err, apperror.ErrPlanNotFound):
        response.Error(c, http.StatusNotFound, "PLAN_NOT_FOUND", "Plan not found")
    case errors.Is(err, apperror.ErrCouponNotFound):
        response.Error(c, http.StatusNotFound, "COUPON_NOT_FOUND", "Coupon not found")
    case errors.Is(err, apperror.ErrCouponCodeExists):
        response.Error(c, http.StatusConflict, "COUPON_CODE_EXISTS", "Coupon code already exists")
    case errors.Is(err, apperror.ErrPaymentNotFound):
        response.Error(c, http.StatusNotFound, "PAYMENT_NOT_FOUND", "Payment not found")
    case errors.Is(err, apperror.ErrPaymentAlreadyRefunded):
        response.Error(c, http.StatusConflict, "ALREADY_REFUNDED", "Payment already refunded")
    case errors.Is(err, apperror.ErrBannerNotFound):
        response.Error(c, http.StatusNotFound, "BANNER_NOT_FOUND", "Banner not found")
    default:
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
    }
}

func (h *AdminHandler) GetDashboard(c *gin.Context) {
    stats, err := h.adminUC.GetDashboard(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, dto.AdminDashboardResponse{
        TotalStudents: stats.TotalStudents, TotalTeachers: stats.TotalTeachers, TotalRevenuePaise: stats.TotalRevenuePaise,
        ActiveSubscriptions: stats.ActiveSubscriptions, ActiveBatches: stats.ActiveBatches,
        UpcomingLiveClasses: stats.UpcomingLiveClasses, AIUsageToday: stats.AIUsageToday,
    }, "")
}

func (h *AdminHandler) AddTeacher(c *gin.Context) {
    var req dto.AddTeacherRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    t, err := h.adminUC.AddTeacher(c.Request.Context(), usecase.AddTeacherInput{Name: req.Name, Email: req.Email, Password: req.Password})
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toTeacherDTO(*t), "Teacher added")
}

func (h *AdminHandler) ApproveTeacher(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid teacher id")
        return
    }
    if err := h.adminUC.ApproveTeacher(c.Request.Context(), id); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Teacher approved")
}

func (h *AdminHandler) EditTeacher(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid teacher id")
        return
    }
    var req dto.EditTeacherRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.adminUC.EditTeacher(c.Request.Context(), usecase.EditTeacherInput{ID: id, Name: req.Name, Email: req.Email})
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Teacher updated")
}

func (h *AdminHandler) SuspendTeacher(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid teacher id")
        return
    }
    var req dto.SuspendTeacherRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.adminUC.SuspendTeacher(c.Request.Context(), id, req.Suspend); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Teacher suspension updated")
}

func (h *AdminHandler) DeleteTeacher(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid teacher id")
        return
    }
    if err := h.adminUC.DeleteTeacher(c.Request.Context(), id); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Teacher deleted")
}

func (h *AdminHandler) ListTeachers(c *gin.Context) {
    teachers, err := h.adminUC.ListTeachers(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    out := make([]dto.TeacherAccountResponse, 0, len(teachers))
    for _, t := range teachers {
        out = append(out, toTeacherDTO(t))
    }
    response.Success(c, http.StatusOK, out, "")
}

func (h *AdminHandler) ListStudents(c *gin.Context) {
    search := c.Query("search")
    limit, _ := strconv.Atoi(c.Query("limit"))
    offset, _ := strconv.Atoi(c.Query("offset"))
    students, err := h.adminUC.ListStudents(c.Request.Context(), search, limit, offset)
    if err != nil {
        handleAdminError(c, err)
        return
    }
    out := make([]dto.StudentAccountResponse, 0, len(students))
    for _, s := range students {
        out = append(out, toStudentDTO(s))
    }
    response.Success(c, http.StatusOK, out, "")
}

func (h *AdminHandler) BlockStudent(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid student id")
        return
    }
    var req dto.BlockStudentRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.adminUC.BlockStudent(c.Request.Context(), id, req.Block); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Student block status updated")
}

func (h *AdminHandler) DeleteStudent(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid student id")
        return
    }
    if err := h.adminUC.DeleteStudent(c.Request.Context(), id); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Student deleted")
}

func (h *AdminHandler) CreatePlan(c *gin.Context) {
    var req dto.CreatePlanRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    plan, err := h.adminUC.CreatePlan(c.Request.Context(), usecase.CreatePlanInput{
        Code: req.Code, Name: req.Name, PricePaise: req.PricePaise, DurationDays: req.DurationDays, IsTrial: req.IsTrial,
    })
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toAdminPlanDTO(*plan), "Plan created")
}

func (h *AdminHandler) UpdatePlan(c *gin.Context) {
    id, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid plan id")
        return
    }
    var req dto.UpdatePlanRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err = h.adminUC.UpdatePlan(c.Request.Context(), usecase.UpdatePlanInput{
        ID: id, Name: req.Name, PricePaise: req.PricePaise, DurationDays: req.DurationDays, IsTrial: req.IsTrial,
    })
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Plan updated")
}

func (h *AdminHandler) EnablePlan(c *gin.Context) {
    id, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid plan id")
        return
    }
    if err := h.adminUC.SetPlanActive(c.Request.Context(), id, true); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Plan enabled")
}

func (h *AdminHandler) DisablePlan(c *gin.Context) {
    id, err := strconv.Atoi(c.Param("id"))
    if err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid plan id")
        return
    }
    if err := h.adminUC.SetPlanActive(c.Request.Context(), id, false); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Plan disabled")
}

func (h *AdminHandler) CreateCoupon(c *gin.Context) {
    var req dto.CreateCouponRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    coupon, err := h.adminUC.CreateCoupon(c.Request.Context(), usecase.CreateCouponInput{
        Code: req.Code, DiscountPercent: req.DiscountPercent, DiscountAmountPaise: req.DiscountAmountPaise,
        MaxUses: req.MaxUses, ValidFrom: req.ValidFrom, ValidUntil: req.ValidUntil,
    })
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toCouponDTO(*coupon), "Coupon created")
}

func (h *AdminHandler) UpdateCoupon(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid coupon id")
        return
    }
    var req dto.UpdateCouponRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.adminUC.UpdateCoupon(c.Request.Context(), usecase.UpdateCouponInput{
        ID: id, DiscountPercent: req.DiscountPercent, DiscountAmountPaise: req.DiscountAmountPaise,
        MaxUses: req.MaxUses, ValidFrom: req.ValidFrom, ValidUntil: req.ValidUntil, IsActive: req.IsActive,
    })
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Coupon updated")
}

func (h *AdminHandler) DeleteCoupon(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid coupon id")
        return
    }
    if err := h.adminUC.DeleteCoupon(c.Request.Context(), id); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Coupon deleted")
}

func (h *AdminHandler) ListCoupons(c *gin.Context) {
    coupons, err := h.adminUC.ListCoupons(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    out := make([]dto.CouponResponse, 0, len(coupons))
    for _, cp := range coupons {
        out = append(out, toCouponDTO(cp))
    }
    response.Success(c, http.StatusOK, out, "")
}

func (h *AdminHandler) ListPayments(c *gin.Context) {
    limit, _ := strconv.Atoi(c.Query("limit"))
    offset, _ := strconv.Atoi(c.Query("offset"))
    payments, err := h.adminUC.ListPayments(c.Request.Context(), limit, offset)
    if err != nil {
        handleAdminError(c, err)
        return
    }
    out := make([]dto.PaymentResponse, 0, len(payments))
    for _, p := range payments {
        out = append(out, toPaymentDTO(p))
    }
    response.Success(c, http.StatusOK, out, "")
}

func (h *AdminHandler) RefundPayment(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid payment id")
        return
    }
    if err := h.adminUC.RefundPayment(c.Request.Context(), id); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Payment refunded")
}

func (h *AdminHandler) GetRevenueReport(c *gin.Context) {
    rep, err := h.adminUC.GetRevenueReport(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, dto.RevenueReportResponse{
        TotalRevenuePaise: rep.TotalRevenuePaise, TotalPayments: rep.TotalPayments, RefundedPaise: rep.RefundedPaise,
    }, "")
}

func (h *AdminHandler) GetStudentsReport(c *gin.Context) {
    rep, err := h.adminUC.GetStudentsReport(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, dto.StudentsReportResponse{
        TotalStudents: rep.TotalStudents, NewStudents30d: rep.NewStudents30d, ActiveTrials: rep.ActiveTrials, PremiumStudents: rep.PremiumStudents,
    }, "")
}

func (h *AdminHandler) GetCoursesReport(c *gin.Context) {
    rep, err := h.adminUC.GetCoursesReport(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, dto.CoursesReportResponse{
        TotalBatches: rep.TotalBatches, TotalSubjects: rep.TotalSubjects, TotalChapters: rep.TotalChapters,
        TotalLectures: rep.TotalLectures, TotalMockTests: rep.TotalMockTests,
    }, "")
}

func (h *AdminHandler) GetSettings(c *gin.Context) {
    settings, err := h.adminUC.GetSettings(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    out := make([]dto.AppSettingResponse, 0, len(settings))
    for _, s := range settings {
        out = append(out, dto.AppSettingResponse{Key: s.Key, Value: s.Value})
    }
    response.Success(c, http.StatusOK, out, "")
}

func (h *AdminHandler) SetSetting(c *gin.Context) {
    key := c.Param("key")
    var req dto.SetSettingRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.adminUC.SetSetting(c.Request.Context(), key, req.Value); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Setting updated")
}

func (h *AdminHandler) CreateBanner(c *gin.Context) {
    var req dto.CreateBannerRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    banner, err := h.adminUC.CreateBanner(c.Request.Context(), usecase.CreateBannerInput{
        Title: req.Title, ImageURL: req.ImageURL, LinkURL: req.LinkURL, DisplayOrder: req.DisplayOrder,
    })
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toBannerDTO(*banner), "Banner created")
}

func (h *AdminHandler) UpdateBanner(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid banner id")
        return
    }
    var req dto.UpdateBannerRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.adminUC.UpdateBanner(c.Request.Context(), usecase.UpdateBannerInput{
        ID: id, Title: req.Title, ImageURL: req.ImageURL, LinkURL: req.LinkURL, DisplayOrder: req.DisplayOrder, IsActive: req.IsActive,
    })
    if err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Banner updated")
}

func (h *AdminHandler) DeleteBanner(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid banner id")
        return
    }
    if err := h.adminUC.DeleteBanner(c.Request.Context(), id); err != nil {
        handleAdminError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Banner deleted")
}

func (h *AdminHandler) ListBanners(c *gin.Context) {
    banners, err := h.adminUC.ListBanners(c.Request.Context())
    if err != nil {
        handleAdminError(c, err)
        return
    }
    out := make([]dto.BannerResponse, 0, len(banners))
    for _, b := range banners {
        out = append(out, toBannerDTO(b))
    }
    response.Success(c, http.StatusOK, out, "")
}
