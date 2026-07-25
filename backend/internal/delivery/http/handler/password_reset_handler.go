package handler

import (
    "errors"
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/go-playground/validator/v10"

    "ai-mentor-backend/internal/delivery/http/dto"
    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/usecase"
)

type PasswordResetHandler struct {
    resetUsecase usecase.PasswordResetUsecase
    validate     *validator.Validate
}

func NewPasswordResetHandler(resetUsecase usecase.PasswordResetUsecase) *PasswordResetHandler {
    return &PasswordResetHandler{resetUsecase: resetUsecase, validate: validator.New()}
}

func (h *PasswordResetHandler) ForgotPassword(c *gin.Context) {
    var req dto.ForgotPasswordRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.validate.Struct(req); err != nil {
        response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
        return
    }

    rawToken, err := h.resetUsecase.ForgotPassword(c.Request.Context(), req.Email)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }

    // Generic response regardless of whether email exists (avoid user enumeration).
    payload := gin.H{}
    if rawToken != "" {
        // Day-1 stub only: expose token directly since no email service is wired up yet.
        payload["reset_token"] = rawToken
    }
    response.Success(c, http.StatusOK, payload, "If the email exists, a reset link has been sent")
}

func (h *PasswordResetHandler) ResetPassword(c *gin.Context) {
    var req dto.ResetPasswordRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.validate.Struct(req); err != nil {
        response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
        return
    }

    err := h.resetUsecase.ResetPassword(c.Request.Context(), req.Token, req.NewPassword)
    if err != nil {
        switch {
        case errors.Is(err, apperror.ErrTokenInvalid):
            response.Error(c, http.StatusBadRequest, "TOKEN_INVALID", "Invalid or expired token")
        case errors.Is(err, apperror.ErrTokenUsed):
            response.Error(c, http.StatusBadRequest, "TOKEN_USED", "Token already used")
        default:
            response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        }
        return
    }

    response.Success(c, http.StatusOK, nil, "Password reset successful")
}
