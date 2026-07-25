package handler

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"

    "ai-mentor-backend/internal/delivery/http/dto"
    "ai-mentor-backend/internal/delivery/http/middleware"
    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/usecase"
)

type DashboardHandler struct {
    dashboardUsecase usecase.DashboardUsecase
}

func NewDashboardHandler(dashboardUsecase usecase.DashboardUsecase) *DashboardHandler {
    return &DashboardHandler{dashboardUsecase: dashboardUsecase}
}

func (h *DashboardHandler) GetDashboard(c *gin.Context) {
    userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

    data, err := h.dashboardUsecase.GetDashboard(c.Request.Context(), userID)
    if err != nil {
        if err == apperror.ErrUserNotFound {
            response.Error(c, http.StatusNotFound, "USER_NOT_FOUND", "User not found")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }

    var selectedExam *dto.ExamOption
    if data.SelectedExam != nil {
        selectedExam = &dto.ExamOption{
            ID:   data.SelectedExam.ID,
            Code: data.SelectedExam.Code,
            Name: data.SelectedExam.Name,
        }
    }

    response.Success(c, http.StatusOK, dto.DashboardResponse{
        Name:             data.User.Name,
        Email:            data.User.Email,
        Premium:          data.User.Premium,
        TrialActive:      data.User.TrialActive(),
        TrialDaysLeft:    data.TrialDaysLeft,
        SelectedExam:     selectedExam,
        StudyStreak:      data.StudyStreak,
        DailyGoal:        data.DailyGoal,
        CompletedToday:   data.CompletedToday,
        ContinueLearning: data.ContinueLearning,
    }, "")
}
