package handler

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"ai-mentor-backend/internal/delivery/http/dto"
	"ai-mentor-backend/internal/delivery/http/response"
	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/usecase"
)

type EarningsHandler struct {
	uc usecase.EarningsUsecase
}

func NewEarningsHandler(uc usecase.EarningsUsecase) *EarningsHandler {
	return &EarningsHandler{uc: uc}
}

func handleEarningsError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, apperror.ErrInvalidInput):
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
	case errors.Is(err, apperror.ErrInvalidCommissionPercent):
		response.Error(c, http.StatusBadRequest, "INVALID_COMMISSION", err.Error())
	case errors.Is(err, apperror.ErrInvalidPayoutAmount):
		response.Error(c, http.StatusBadRequest, "INVALID_PAYOUT_AMOUNT", err.Error())
	default:
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
	}
}

func toRevenueMonthDTOs(months []entity.RevenueMonth) []dto.RevenueMonthResponse {
	out := make([]dto.RevenueMonthResponse, 0, len(months))
	for _, m := range months {
		out = append(out, dto.RevenueMonthResponse{Month: m.Month, AmountPaise: m.AmountPaise})
	}
	return out
}

func toPayoutDTOs(payouts []entity.TeacherPayout) []dto.TeacherPayoutResponse {
	out := make([]dto.TeacherPayoutResponse, 0, len(payouts))
	for _, p := range payouts {
		out = append(out, dto.TeacherPayoutResponse{
			ID: p.ID, TeacherID: p.TeacherID, AmountPaise: p.AmountPaise, Note: p.Note, CreatedAt: p.CreatedAt,
		})
	}
	return out
}

func toSummaryDTO(s *entity.TeacherEarningsSummary) dto.TeacherEarningsSummaryResponse {
	return dto.TeacherEarningsSummaryResponse{
		TeacherID:            s.TeacherID,
		CommissionPercent:    s.CommissionPercent,
		TotalStudents:        s.TotalStudents,
		TotalEarningsPaise:   s.TotalEarningsPaise,
		MonthlyEarningsPaise: s.MonthlyEarnings,
		PaidAmountPaise:      s.PaidAmountPaise,
		PendingPayoutPaise:   s.PendingPayoutPaise,
		RevenueHistory:       toRevenueMonthDTOs(s.RevenueHistory),
		RecentPayouts:        toPayoutDTOs(s.RecentPayouts),
	}
}

func toTeacherStudentDTOs(students []entity.TeacherStudent) []dto.TeacherStudentResponse {
	out := make([]dto.TeacherStudentResponse, 0, len(students))
	for _, s := range students {
		out = append(out, dto.TeacherStudentResponse{
			ID: s.ID, Name: s.Name, Email: s.Email, BatchTitles: s.BatchTitles, LastActive: s.LastActive,
		})
	}
	return out
}

// GetMySummary handles GET /teacher/earnings.
func (h *EarningsHandler) GetMySummary(c *gin.Context) {
	summary, err := h.uc.GetSummary(c.Request.Context(), currentUserID(c))
	if err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toSummaryDTO(summary), "")
}

// GetMyPayouts handles GET /teacher/earnings/payouts.
func (h *EarningsHandler) GetMyPayouts(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	payouts, err := h.uc.ListPayouts(c.Request.Context(), currentUserID(c), limit)
	if err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toPayoutDTOs(payouts), "")
}

// GetMyStudents handles GET /teacher/earnings/students.
func (h *EarningsHandler) GetMyStudents(c *gin.Context) {
	students, err := h.uc.ListStudents(c.Request.Context(), currentUserID(c))
	if err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toTeacherStudentDTOs(students), "")
}

// GetTeacherSummary handles GET /admin/teachers/:id/earnings.
func (h *EarningsHandler) GetTeacherSummary(c *gin.Context) {
	summary, err := h.uc.GetSummary(c.Request.Context(), c.Param("id"))
	if err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toSummaryDTO(summary), "")
}

// ListTeacherPayouts handles GET /admin/teachers/:id/payouts.
func (h *EarningsHandler) ListTeacherPayouts(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	payouts, err := h.uc.ListPayouts(c.Request.Context(), c.Param("id"), limit)
	if err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toPayoutDTOs(payouts), "")
}

// SetCommission handles PATCH /admin/teachers/:id/commission.
func (h *EarningsHandler) SetCommission(c *gin.Context) {
	var req dto.SetCommissionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.uc.SetCommissionPercent(c.Request.Context(), c.Param("id"), req.CommissionPercent); err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Commission rate updated")
}

// CreatePayout handles POST /admin/teachers/:id/payouts.
func (h *EarningsHandler) CreatePayout(c *gin.Context) {
	var req dto.CreatePayoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	payout, err := h.uc.CreatePayout(c.Request.Context(), c.Param("id"), req.AmountPaise, req.Note, currentUserID(c))
	if err != nil {
		handleEarningsError(c, err)
		return
	}
	response.Success(c, http.StatusCreated, dto.TeacherPayoutResponse{
		ID: payout.ID, TeacherID: payout.TeacherID, AmountPaise: payout.AmountPaise, Note: payout.Note, CreatedAt: payout.CreatedAt,
	}, "Payout recorded")
}
