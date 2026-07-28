package handler

import (
	"errors"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"

	"ai-mentor-backend/internal/delivery/http/dto"
	"ai-mentor-backend/internal/delivery/http/middleware"
	"ai-mentor-backend/internal/delivery/http/response"
	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/usecase"
)

type StudyPlanHandler struct {
	planUsecase usecase.StudyPlanUsecase
	validate    *validator.Validate
}

func NewStudyPlanHandler(planUsecase usecase.StudyPlanUsecase) *StudyPlanHandler {
	return &StudyPlanHandler{planUsecase: planUsecase, validate: validator.New()}
}

func toStudyPlanDTO(p entity.StudyPlan) dto.StudyPlanResponse {
	return dto.StudyPlanResponse{
		ID:          p.ID,
		Date:        p.Date,
		Goal:        p.Goal,
		IsCompleted: p.IsCompleted,
		CreatedAt:   p.CreatedAt,
	}
}

// ListPlans handles GET /api/planner/plans.
func (h *StudyPlanHandler) ListPlans(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	plans, err := h.planUsecase.ListPlans(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	out := make([]dto.StudyPlanResponse, 0, len(plans))
	for _, p := range plans {
		out = append(out, toStudyPlanDTO(p))
	}
	response.Success(c, http.StatusOK, out, "")
}

// CreatePlan handles POST /api/planner/plans.
func (h *StudyPlanHandler) CreatePlan(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	var req dto.CreateStudyPlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.validate.Struct(req); err != nil {
		response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	plan, err := h.planUsecase.CreatePlan(c.Request.Context(), userID, req.Date, req.Goal, req.IsCompleted)
	if err != nil {
		log.Println("CreatePlan error:", err)
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusCreated, toStudyPlanDTO(*plan), "Plan created")
}

// UpdatePlan handles PUT /api/planner/plans/:id.
func (h *StudyPlanHandler) UpdatePlan(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	planID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid plan id")
		return
	}

	var req dto.UpdateStudyPlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.validate.Struct(req); err != nil {
		response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	plan, err := h.planUsecase.UpdatePlan(c.Request.Context(), userID, planID, req.Date, req.Goal, req.IsCompleted)
	if err != nil {
		if errors.Is(err, apperror.ErrStudyPlanNotFound) {
			response.Error(c, http.StatusNotFound, "PLAN_NOT_FOUND", "Plan not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, toStudyPlanDTO(*plan), "Plan updated")
}

// DeletePlan handles DELETE /api/planner/plans/:id.
func (h *StudyPlanHandler) DeletePlan(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	planID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid plan id")
		return
	}

	if err := h.planUsecase.DeletePlan(c.Request.Context(), userID, planID); err != nil {
		if errors.Is(err, apperror.ErrStudyPlanNotFound) {
			response.Error(c, http.StatusNotFound, "PLAN_NOT_FOUND", "Plan not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, nil, "Plan deleted")
}

// CompletePlan handles POST /api/planner/plans/:id/complete.
func (h *StudyPlanHandler) CompletePlan(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	planID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid plan id")
		return
	}

	plan, err := h.planUsecase.CompletePlan(c.Request.Context(), userID, planID)
	if err != nil {
		if errors.Is(err, apperror.ErrStudyPlanNotFound) {
			response.Error(c, http.StatusNotFound, "PLAN_NOT_FOUND", "Plan not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, toStudyPlanDTO(*plan), "Plan marked complete")
}