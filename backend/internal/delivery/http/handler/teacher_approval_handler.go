package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"

	"ai-mentor-backend/internal/delivery/http/dto"
	"ai-mentor-backend/internal/delivery/http/response"
	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/usecase"
)

// TeacherApprovalHandler exposes the admin Teacher Approval queue: pending
// applications, approve, reject, and teacher suspension. It reuses the
// TeacherApplicationResponse DTO and toApplicationDTO mapper already defined
// alongside TeacherApplicationHandler.
type TeacherApprovalHandler struct {
	uc usecase.TeacherApprovalUsecase
}

func NewTeacherApprovalHandler(uc usecase.TeacherApprovalUsecase) *TeacherApprovalHandler {
	return &TeacherApprovalHandler{uc: uc}
}

func handleApprovalError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, apperror.ErrTeacherApplicationNotFound):
		response.Error(c, http.StatusNotFound, "NOT_FOUND", err.Error())
	case errors.Is(err, apperror.ErrTeacherNotFound):
		response.Error(c, http.StatusNotFound, "NOT_FOUND", err.Error())
	case errors.Is(err, apperror.ErrTeacherApplicationNotEditable):
		response.Error(c, http.StatusConflict, "NOT_EDITABLE", err.Error())
	case errors.Is(err, apperror.ErrInvalidInput):
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
	default:
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
	}
}

// PendingApplications handles GET /admin/teacher-approvals/pending.
func (h *TeacherApprovalHandler) PendingApplications(c *gin.Context) {
	p := parsePagination(c)
	apps, total, err := h.uc.PendingApplications(c.Request.Context(), p.Limit, p.Offset)
	if err != nil {
		handleApprovalError(c, err)
		return
	}
	out := make([]dto.TeacherApplicationResponse, 0, len(apps))
	for _, a := range apps {
		out = append(out, toApplicationDTO(a))
	}
	response.Success(c, http.StatusOK, dto.PagedResponse{
		Items: out,
		Meta:  dto.PageMeta{Total: total, Limit: p.Limit, Offset: p.Offset},
	}, "")
}

// Approve handles PATCH /admin/teacher-approvals/:id/approve.
func (h *TeacherApprovalHandler) Approve(c *gin.Context) {
	var req dto.ReviewTeacherApplicationRequest
	_ = c.ShouldBindJSON(&req)
	if err := h.uc.Approve(c.Request.Context(), c.Param("id"), currentUserID(c), req.Note); err != nil {
		handleApprovalError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Application approved - the account is now a teacher")
}

// Reject handles PATCH /admin/teacher-approvals/:id/reject.
func (h *TeacherApprovalHandler) Reject(c *gin.Context) {
	var req dto.ReviewTeacherApplicationRequest
	_ = c.ShouldBindJSON(&req)
	if err := h.uc.Reject(c.Request.Context(), c.Param("id"), currentUserID(c), req.Note); err != nil {
		handleApprovalError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Application rejected")
}

// SuspendTeacher handles PATCH /admin/teacher-approvals/teachers/:id/suspend.
func (h *TeacherApprovalHandler) SuspendTeacher(c *gin.Context) {
	var req dto.SuspendTeacherRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.uc.SuspendTeacher(c.Request.Context(), c.Param("id"), req.Suspend); err != nil {
		handleApprovalError(c, err)
		return
	}
	msg := "Teacher suspended"
	if !req.Suspend {
		msg = "Teacher reactivated"
	}
	response.Success(c, http.StatusOK, nil, msg)
}
