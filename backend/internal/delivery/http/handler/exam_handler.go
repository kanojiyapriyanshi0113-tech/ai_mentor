package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	"ai-mentor-backend/internal/delivery/http/dto"
	"ai-mentor-backend/internal/delivery/http/middleware"
	"ai-mentor-backend/internal/delivery/http/response"
	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/usecase"
)

type ExamHandler struct {
	examUsecase usecase.ExamUsecase
	validate    *validator.Validate
}

func NewExamHandler(examUsecase usecase.ExamUsecase) *ExamHandler {
	return &ExamHandler{examUsecase: examUsecase, validate: validator.New()}
}

func (h *ExamHandler) ListExams(c *gin.Context) {
	exams, err := h.examUsecase.ListExams(c.Request.Context())
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	options := make([]dto.ExamOption, 0, len(exams))
	for _, e := range exams {
		options = append(options, dto.ExamOption{ID: e.ID, Code: e.Code, Name: e.Name, Category: e.Category})
	}

	response.Success(c, http.StatusOK, options, "")
}

func (h *ExamHandler) SelectExam(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	var req dto.SelectExamRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.validate.Struct(req); err != nil {
		response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	exam, err := h.examUsecase.SelectExam(c.Request.Context(), userID, req.ExamID)
	if err != nil {
		if errors.Is(err, apperror.ErrExamNotFound) {
			response.Error(c, http.StatusNotFound, "EXAM_NOT_FOUND", "Exam not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, dto.SelectExamResponse{
		ExamID:   exam.ID,
		Code:     exam.Code,
		Name:     exam.Name,
		Category: exam.Category,
	}, "Exam selected")
}
