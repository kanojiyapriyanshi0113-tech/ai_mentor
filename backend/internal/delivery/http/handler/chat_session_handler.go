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
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/usecase"
)

type ChatSessionHandler struct {
	sessionUsecase usecase.ChatSessionUsecase
	validate       *validator.Validate
}

func NewChatSessionHandler(sessionUsecase usecase.ChatSessionUsecase) *ChatSessionHandler {
	return &ChatSessionHandler{sessionUsecase: sessionUsecase, validate: validator.New()}
}

func toChatSessionDTO(s entity.ChatSession) dto.ChatSessionResponse {
	return dto.ChatSessionResponse{
		ID:        s.ID,
		Title:     s.Title,
		CreatedAt: s.CreatedAt,
		UpdatedAt: s.UpdatedAt,
	}
}

func toAIChatMessageDTOs(messages []entity.AIChat) []dto.AIChatMessage {
	out := make([]dto.AIChatMessage, 0, len(messages))
	for _, m := range messages {
		out = append(out, dto.AIChatMessage{
			Role:      m.Role,
			Message:   m.Message,
			CreatedAt: m.CreatedAt,
		})
	}
	return out
}

func (h *ChatSessionHandler) CreateSession(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	var req dto.CreateChatSessionRequest
	// Title is optional, so an empty body is valid — only reject genuinely
	// malformed JSON.
	if err := c.ShouldBindJSON(&req); err != nil && err.Error() != "EOF" {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.validate.Struct(req); err != nil {
		response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	session, err := h.sessionUsecase.CreateSession(c.Request.Context(), userID, req.Title)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusCreated, toChatSessionDTO(*session), "Session created")
}

func (h *ChatSessionHandler) ListSessions(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	sessions, err := h.sessionUsecase.ListSessions(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	out := make([]dto.ChatSessionResponse, 0, len(sessions))
	for _, s := range sessions {
		out = append(out, toChatSessionDTO(s))
	}
	response.Success(c, http.StatusOK, out, "")
}

func (h *ChatSessionHandler) GetSession(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	sessionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid session id")
		return
	}

	result, err := h.sessionUsecase.GetSession(c.Request.Context(), userID, sessionID)
	if err != nil {
		if errors.Is(err, apperror.ErrChatSessionNotFound) {
			response.Error(c, http.StatusNotFound, "SESSION_NOT_FOUND", "Chat session not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, dto.ChatSessionDetailResponse{
		Session:  toChatSessionDTO(result.Session),
		Messages: toAIChatMessageDTOs(result.Messages),
	}, "")
}

func (h *ChatSessionHandler) RenameSession(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	sessionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid session id")
		return
	}

	var req dto.RenameChatSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
		return
	}
	if err := h.validate.Struct(req); err != nil {
		response.Error(c, http.StatusBadRequest, "VALIDATION_ERROR", err.Error())
		return
	}

	if err := h.sessionUsecase.RenameSession(c.Request.Context(), userID, sessionID, req.Title); err != nil {
		if errors.Is(err, apperror.ErrChatSessionNotFound) {
			response.Error(c, http.StatusNotFound, "SESSION_NOT_FOUND", "Chat session not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, nil, "Session renamed")
}

func (h *ChatSessionHandler) DeleteSession(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	sessionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid session id")
		return
	}

	if err := h.sessionUsecase.DeleteSession(c.Request.Context(), userID, sessionID); err != nil {
		if errors.Is(err, apperror.ErrChatSessionNotFound) {
			response.Error(c, http.StatusNotFound, "SESSION_NOT_FOUND", "Chat session not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}

	response.Success(c, http.StatusOK, nil, "Session deleted")
}