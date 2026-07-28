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

type TeacherApplicationManageHandler struct {
	uc usecase.TeacherApplicationManageUsecase
}

func NewTeacherApplicationManageHandler(uc usecase.TeacherApplicationManageUsecase) *TeacherApplicationManageHandler {
	return &TeacherApplicationManageHandler{uc: uc}
}

// Update handles PUT /teacher-application/me — edit an application that's
// still pending or was sent back for changes.
func (h *TeacherApplicationManageHandler) Update(c *gin.Context) {
	var req dto.UpdateTeacherApplicationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	app, err := h.uc.Update(c.Request.Context(), currentUserID(c), usecase.UpdateTeacherApplicationInput{
		FullName: req.FullName, Email: req.Email, Phone: req.Phone, Qualification: req.Qualification,
		ExperienceYears: req.ExperienceYears, ExamExpertise: req.ExamExpertise, Subjects: req.Subjects,
		About: req.About, ResumeURL: req.ResumeURL, DegreeURL: req.DegreeURL, GovtIDURL: req.GovtIDURL,
		PhotoURL: req.PhotoURL, DemoVideoURL: req.DemoVideoURL, ExpectedSalary: req.ExpectedSalary,
	})
	if err != nil {
		handleManageApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toApplicationDTO(*app), "Application updated")
}

// Cancel handles DELETE /teacher-application/me — the applicant withdraws
// their own application.
func (h *TeacherApplicationManageHandler) Cancel(c *gin.Context) {
	if err := h.uc.Cancel(c.Request.Context(), currentUserID(c)); err != nil {
		handleManageApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Application withdrawn")
}

// SearchList handles GET /admin/teacher-applications/search — like the
// existing List but with a free-text search term and total-count paging.
func (h *TeacherApplicationManageHandler) SearchList(c *gin.Context) {
	status := c.Query("status")
	search := c.Query("search")
	p := parsePagination(c)

	apps, total, err := h.uc.SearchList(c.Request.Context(), status, search, p.Limit, p.Offset)
	if err != nil {
		handleManageApplicationError(c, err)
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

func handleManageApplicationError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, apperror.ErrTeacherApplicationNotFound):
		response.Error(c, http.StatusNotFound, "NOT_FOUND", err.Error())
	case errors.Is(err, apperror.ErrTeacherApplicationNotEditable):
		response.Error(c, http.StatusConflict, "NOT_EDITABLE", err.Error())
	case errors.Is(err, apperror.ErrForbidden):
		response.Error(c, http.StatusForbidden, "FORBIDDEN", err.Error())
	case errors.Is(err, apperror.ErrInvalidInput):
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
	default:
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
	}
}
