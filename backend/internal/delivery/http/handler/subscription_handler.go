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
"ai-mentor-backend/internal/usecase"
)

type SubscriptionHandler struct {
subscriptionUsecase usecase.SubscriptionUsecase
validate            *validator.Validate
}

func NewSubscriptionHandler(subscriptionUsecase usecase.SubscriptionUsecase) *SubscriptionHandler {
return &SubscriptionHandler{subscriptionUsecase: subscriptionUsecase, validate: validator.New()}
}

func toSubscriptionDTO(d *usecase.SubscriptionDetail) dto.SubscriptionResponse {
return dto.SubscriptionResponse{
PlanCode: d.Plan.Code, PlanName: d.Plan.Name, Status: d.Subscription.Status,
IsTrial: d.Plan.IsTrial, StartedAt: d.Subscription.StartedAt, ExpiresAt: d.Subscription.ExpiresAt,
DaysLeft: d.DaysLeft, Features: d.Features,
}
}

// GetSubscription returns the plan-limits + usage + remaining summary
// consumed by the Flutter Profile screen.
func (h *SubscriptionHandler) GetSubscription(c *gin.Context) {
userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)
summary, err := h.subscriptionUsecase.GetSubscriptionSummary(c.Request.Context(), userID)
	if err != nil {
		log.Printf("GetSubscription error: %v", err)
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}
response.Success(c, http.StatusOK, dto.SubscriptionSummaryResponse{
CurrentPlan:          summary.CurrentPlan,
TrialDaysLeft:        summary.TrialDaysLeft,
AIQuestionsRemaining: summary.AIQuestionsRemaining,
ChaptersRemaining:    summary.ChaptersRemaining,
VideosRemaining:      summary.VideosRemaining,
PDFNotesRemaining:    summary.PDFNotesRemaining,
MockTestsRemaining:   summary.MockTestsRemaining,
}, "")
}

func (h *SubscriptionHandler) ListPlans(c *gin.Context) {
plans, err := h.subscriptionUsecase.ListPlans(c.Request.Context())
if err != nil {
response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
return
}
out := make([]dto.PlanResponse, 0, len(plans))
for _, p := range plans {
out = append(out, dto.PlanResponse{Code: p.Code, Name: p.Name, PricePaise: p.PricePaise, DurationDays: p.DurationDays, IsTrial: p.IsTrial})
}
response.Success(c, http.StatusOK, out, "")
}

func (h *SubscriptionHandler) UpgradeSubscription(c *gin.Context) {
userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

var req dto.UpgradeSubscriptionRequest
if err := c.ShouldBindJSON(&req); err != nil {
response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
return
}
if err := h.validate.Struct(req); err != nil {
response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
return
}

detail, err := h.subscriptionUsecase.UpgradePlan(c.Request.Context(), userID, req.PlanCode)
if err != nil {
if errors.Is(err, apperror.ErrPlanNotFound) {
response.Error(c, http.StatusNotFound, "PLAN_NOT_FOUND", "Plan not found")
return
}
response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
return
}

response.Success(c, http.StatusOK, toSubscriptionDTO(detail), "Plan upgraded")
}

func (h *SubscriptionHandler) GetFeatures(c *gin.Context) {
userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)
features, err := h.subscriptionUsecase.GetFeatures(c.Request.Context(), userID)
if err != nil {
response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
return
}
response.Success(c, http.StatusOK, features, "")
}
