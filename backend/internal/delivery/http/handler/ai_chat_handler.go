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

type AIChatHandler struct {
	chatUsecase usecase.AIChatUsecase
	validate    *validator.Validate
}

func NewAIChatHandler(chatUsecase usecase.AIChatUsecase) *AIChatHandler {
	return &AIChatHandler{chatUsecase: chatUsecase, validate: validator.New()}
}

func (h *AIChatHandler) SendMessage(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	var req dto.AIChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.validate.Struct(req); err != nil {
		response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	sessionID := uuid.Nil
	if req.SessionID != "" {
		parsed, err := uuid.Parse(req.SessionID)
		if err != nil {
			response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid session_id")
			return
		}
		sessionID = parsed
	}

	reply, resolvedSessionID, err := h.chatUsecase.SendMessage(c.Request.Context(), userID, sessionID, req.Message)
	if err != nil {
		if errors.Is(err, apperror.ErrAIProviderFailed) {
			response.Error(c, http.StatusServiceUnavailable, "AI_PROVIDER_ERROR", "AI service is unavailable, try again")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, dto.AIChatResponse{
		Reply:     reply,
		SessionID: resolvedSessionID.String(),
	}, "")
}