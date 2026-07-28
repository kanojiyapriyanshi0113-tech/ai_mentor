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

type TeacherApplicationHandler struct {
	uc usecase.TeacherApplicationUsecase
}

func NewTeacherApplicationHandler(uc usecase.TeacherApplicationUsecase) *TeacherApplicationHandler {
	return &TeacherApplicationHandler{uc: uc}
}

func toApplicationDTO(a entity.TeacherApplication) dto.TeacherApplicationResponse {
	return dto.TeacherApplicationResponse{
		ID: a.ID, UserID: a.UserID, FullName: a.FullName, Email: a.Email, Phone: a.Phone,
		Qualification: a.Qualification, ExperienceYears: a.ExperienceYears, ExamExpertise: a.ExamExpertise,
		Subjects: a.Subjects, About: a.About, ResumeURL: a.ResumeURL, DegreeURL: a.DegreeURL,
		GovtIDURL: a.GovtIDURL, PhotoURL: a.PhotoURL, DemoVideoURL: a.DemoVideoURL,
		ExpectedSalary: a.ExpectedSalary, Status: string(a.Status), AdminNote: a.AdminNote,
		ReviewedBy: a.ReviewedBy, ReviewedAt: a.ReviewedAt, CreatedAt: a.CreatedAt, UpdatedAt: a.UpdatedAt,
	}
}

func handleApplicationError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, apperror.ErrTeacherApplicationNotFound):
		response.Error(c, http.StatusNotFound, "NOT_FOUND", err.Error())
	case errors.Is(err, apperror.ErrTeacherApplicationOpenExists):
		response.Error(c, http.StatusConflict, "APPLICATION_EXISTS", err.Error())
	case errors.Is(err, apperror.ErrInvalidInput):
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
	default:
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
	}
}

// Submit handles POST /teacher-application â€” a student applies to become a teacher.
func (h *TeacherApplicationHandler) Submit(c *gin.Context) {
	var req dto.SubmitTeacherApplicationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	app, err := h.uc.Submit(c.Request.Context(), usecase.SubmitTeacherApplicationInput{
		UserID: currentUserID(c), FullName: req.FullName, Email: req.Email, Phone: req.Phone,
		Qualification: req.Qualification, ExperienceYears: req.ExperienceYears, ExamExpertise: req.ExamExpertise,
		Subjects: req.Subjects, About: req.About, ResumeURL: req.ResumeURL, DegreeURL: req.DegreeURL,
		GovtIDURL: req.GovtIDURL, PhotoURL: req.PhotoURL, DemoVideoURL: req.DemoVideoURL,
		ExpectedSalary: req.ExpectedSalary,
	})
	if err != nil {
		handleApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusCreated, toApplicationDTO(*app), "Application submitted for review")
}

// GetMine handles GET /teacher-application/me.
func (h *TeacherApplicationHandler) GetMine(c *gin.Context) {
	app, err := h.uc.GetMine(c.Request.Context(), currentUserID(c))
	if errors.Is(err, apperror.ErrTeacherApplicationNotFound) {
		response.Success(c, http.StatusOK, nil, "No application yet")
		return
	}
	if err != nil {
		handleApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toApplicationDTO(*app), "")
}

// List handles GET /admin/teacher-applications.
func (h *TeacherApplicationHandler) List(c *gin.Context) {
	status := c.Query("status")
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	apps, err := h.uc.List(c.Request.Context(), status, limit, offset)
	if err != nil {
		handleApplicationError(c, err)
		return
	}
	out := make([]dto.TeacherApplicationResponse, 0, len(apps))
	for _, a := range apps {
		out = append(out, toApplicationDTO(a))
	}
	response.Success(c, http.StatusOK, out, "")
}

// Get handles GET /admin/teacher-applications/:id.
func (h *TeacherApplicationHandler) Get(c *gin.Context) {
	app, err := h.uc.Get(c.Request.Context(), c.Param("id"))
	if err != nil {
		handleApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, toApplicationDTO(*app), "")
}

// Approve handles PATCH /admin/teacher-applications/:id/approve.
func (h *TeacherApplicationHandler) Approve(c *gin.Context) {
	var req dto.ReviewTeacherApplicationRequest
	_ = c.ShouldBindJSON(&req)
	if err := h.uc.Approve(c.Request.Context(), c.Param("id"), currentUserID(c), req.Note); err != nil {
		handleApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Application approved - the account is now a teacher")
}

// Reject handles PATCH /admin/teacher-applications/:id/reject.
func (h *TeacherApplicationHandler) Reject(c *gin.Context) {
	var req dto.ReviewTeacherApplicationRequest
	_ = c.ShouldBindJSON(&req)
	if err := h.uc.Reject(c.Request.Context(), c.Param("id"), currentUserID(c), req.Note); err != nil {
		handleApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Application rejected")
}

// RequestChanges handles PATCH /admin/teacher-applications/:id/request-changes.
func (h *TeacherApplicationHandler) RequestChanges(c *gin.Context) {
	var req dto.ReviewTeacherApplicationRequest
	_ = c.ShouldBindJSON(&req)
	if err := h.uc.RequestChanges(c.Request.Context(), c.Param("id"), currentUserID(c), req.Note); err != nil {
		handleApplicationError(c, err)
		return
	}
	response.Success(c, http.StatusOK, nil, "Changes requested")
}