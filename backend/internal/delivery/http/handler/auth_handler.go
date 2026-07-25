package handler

import (
    "errors"
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/go-playground/validator/v10"

    "ai-mentor-backend/internal/delivery/http/dto"
    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/usecase"
)

type AuthHandler struct {
    authUsecase usecase.AuthUsecase
    validate    *validator.Validate
}

func NewAuthHandler(authUsecase usecase.AuthUsecase) *AuthHandler {
    return &AuthHandler{authUsecase: authUsecase, validate: validator.New()}
}

func toAuthResponse(token string, u *entity.User) dto.AuthResponse {
    return dto.AuthResponse{
        Token: token,
        User: dto.UserBrief{
            ID:             u.ID.String(),
            Name:           u.Name,
            Email:          u.Email,
            Premium:        u.Premium,
            TrialStartDate: u.TrialStartDate.Format("2006-01-02T15:04:05Z07:00"),
            TrialEndDate:   u.TrialEndDate.Format("2006-01-02T15:04:05Z07:00"),
        },
    }
}

func (h *AuthHandler) Register(c *gin.Context) {
    var req dto.RegisterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.validate.Struct(req); err != nil {
        response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
        return
    }

    token, user, err := h.authUsecase.Register(c.Request.Context(), req.Name, req.Email, req.Password)
    if err != nil {
        if errors.Is(err, apperror.ErrEmailAlreadyExists) {
            response.Error(c, http.StatusConflict, "EMAIL_EXISTS", "Email already registered")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }

    response.Success(c, http.StatusCreated, toAuthResponse(token, user), "Registration successful")
}

func (h *AuthHandler) Login(c *gin.Context) {
    var req dto.LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.validate.Struct(req); err != nil {
        response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
        return
    }

    token, user, err := h.authUsecase.Login(c.Request.Context(), req.Email, req.Password)
    if err != nil {
        if errors.Is(err, apperror.ErrInvalidCredentials) {
            response.Error(c, http.StatusUnauthorized, "INVALID_CREDENTIALS", "Invalid email or password")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }

    response.Success(c, http.StatusOK, toAuthResponse(token, user), "Login successful")
}
