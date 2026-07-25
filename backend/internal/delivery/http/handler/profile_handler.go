package handler

import (
    "errors"
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/go-playground/validator/v10"

    "ai-mentor-backend/internal/delivery/http/dto"
    "ai-mentor-backend/internal/delivery/http/middleware"
    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/usecase"
    "github.com/google/uuid"
)

type ProfileHandler struct {
    profileUsecase usecase.ProfileUsecase
    validate       *validator.Validate
}

func NewProfileHandler(profileUsecase usecase.ProfileUsecase) *ProfileHandler {
    return &ProfileHandler{profileUsecase: profileUsecase, validate: validator.New()}
}

func toProfileDTO(u *entity.User) dto.ProfileResponse {
    return dto.ProfileResponse{
        ID:             u.ID.String(),
        Name:           u.Name,
        Email:          u.Email,
        Premium:        u.Premium,
        TrialActive:    u.TrialActive(),
        TrialStartDate: u.TrialStartDate,
        TrialEndDate:   u.TrialEndDate,
        CreatedAt:      u.CreatedAt,
    }
}

func (h *ProfileHandler) GetProfile(c *gin.Context) {
    userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

    user, err := h.profileUsecase.GetProfile(c.Request.Context(), userID)
    if err != nil || user == nil {
        response.Error(c, http.StatusNotFound, "USER_NOT_FOUND", "User not found")
        return
    }

    response.Success(c, http.StatusOK, toProfileDTO(user), "")
}

func (h *ProfileHandler) UpdateProfile(c *gin.Context) {
    userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

    var req dto.UpdateProfileRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.validate.Struct(req); err != nil {
        response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
        return
    }

    user, err := h.profileUsecase.UpdateProfile(c.Request.Context(), userID, req.Name)
    if err != nil {
        if errors.Is(err, apperror.ErrUserNotFound) {
            response.Error(c, http.StatusNotFound, "USER_NOT_FOUND", "User not found")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }

    response.Success(c, http.StatusOK, toProfileDTO(user), "Profile updated")
}
