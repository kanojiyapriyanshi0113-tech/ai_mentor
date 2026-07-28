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

type TeacherPayoutHandler struct {
	uc usecase.TeacherPayoutUsecase
}

func NewTeacherPayoutHandler(uc usecase.TeacherPayoutUsecase) *TeacherPayoutHandler {
	return &TeacherPayoutHandler{uc: uc}
}

func handleTeacherPayoutError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, apperror.ErrInvalidInput):
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
	case errors.Is(err, apperror.ErrInvalidPayoutAmount):
		response.Error(c, http.StatusBadRequest, "INVALID_PAYOUT_AMOUNT", err.Error())
	case errors.Is(err, apperror.ErrPayoutNotFound):
		response.Error(c, http.StatusNotFound, "PAYOUT_NOT_FOUND", err.Error())
	case errors.Is(err, apperror.ErrPayoutAlreadyPaid):
		response.Error(c, http.StatusConflict, "PAYOUT_ALREADY_PAID", err.Error())
	default:
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
	}
}

func toTeacherPayoutRecordDTO(p *entity.TeacherPayoutRecord) dto.TeacherPayoutRecordResponse {
	out := dto.TeacherPayoutRecordResponse{
		ID:          p.ID.String(),
		TeacherID:   p.TeacherID.String(),
		AmountPaise: p.AmountPaise,
		Note:        p.Note,
		Status:      string(p.Status),
		CreatedBy:   p.CreatedBy.String(),
		PaidAt:      p.PaidAt,
		CreatedAt:   p.CreatedAt,
		UpdatedAt:   p.UpdatedAt,
	}
	if p.PaidBy != nil {
		out.PaidBy = p.PaidBy.String()
	}
	return out
}

func toTeacherPayoutRecordDTOs(payouts []entity.TeacherPayoutRecord) []dto.TeacherPayoutRecordResponse {
	out := make([]dto.TeacherPayoutRecordResponse, 0, len(payouts))
	for i := range payouts {
		out = append(out, toTeacherPayoutRecordDTO(&payouts[i]))
	}
	return out
}

func parsePayoutPageParams(c *gin.Context) (limit, offset int) {
	limit, _ = strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ = strconv.Atoi(c.DefaultQuery("offset", "0"))
	return limit, offset
}

// AdminCreatePayout handles POST /admin/teachers/:id/teacher-payouts.
// Admin Create Payout: records a new pending payout for the teacher.
func (h *TeacherPayoutHandler) AdminCreatePayout(c *gin.Context) {
	var req dto.CreateTeacherPayoutRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	payout, err := h.uc.CreatePayout(c.Request.Context(), c.Param("id"), req.AmountPaise, req.Note, currentUserID(c))
	if err != nil {
		handleTeacherPayoutError(c, err)
		return
	}
	response.Success(c, http.StatusCreated, toTeacherPayoutRecordDTO(payout), "Payout created")
}

// AdminMarkPaid handles PATCH /admin/teacher-payouts/:payoutId/mark-paid.
// Mark Paid: confirms a pending payout as paid.
func (h *TeacherPayoutHandler) AdminMarkPaid(c *gin.Context) {
	payout, err := h.uc.MarkPaid(c.Request.Context(), c.Param("payoutId"), currentUserID(c))
	if err != nil {
		handleTeacherPayoutError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toTeacherPayoutRecordDTO(payout), "Payout marked as paid")
}

// AdminListPayouts handles GET /admin/teacher-payouts.
// View Payouts: lists payout records across all teachers, optionally
// filtered by ?status=pending|paid and/or ?teacher_id=.
func (h *TeacherPayoutHandler) AdminListPayouts(c *gin.Context) {
	limit, offset := parsePayoutPageParams(c)
	payouts, err := h.uc.ListPayouts(c.Request.Context(), c.Query("status"), c.Query("teacher_id"), limit, offset)
	if err != nil {
		handleTeacherPayoutError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toTeacherPayoutRecordDTOs(payouts), "")
}

// GetMyPayoutHistory handles GET /teacher/teacher-payouts.
// Teacher Payout History: the authenticated teacher's own payout records.
func (h *TeacherPayoutHandler) GetMyPayoutHistory(c *gin.Context) {
	limit, offset := parsePayoutPageParams(c)
	payouts, err := h.uc.GetPayoutHistory(c.Request.Context(), currentUserID(c), limit, offset)
	if err != nil {
		handleTeacherPayoutError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toTeacherPayoutRecordDTOs(payouts), "")
}
