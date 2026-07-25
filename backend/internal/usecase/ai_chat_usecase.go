package usecase

import (
	"context"
	"fmt"
	"log"
	"strings"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

// maxHistoryMessages caps how many prior messages (user+assistant combined)
// are sent to the AI provider as context, to bound token usage on long
// sessions. The most recent messages are kept; older ones are dropped.
const maxHistoryMessages = 20

// systemPrompt anchors the AI's role and tone across every request.
const systemPrompt = "You are an AI mentor helping students prepare for competitive exams. " +
	"Be clear, encouraging, and build on the conversation so far rather than answering each " +
	"message in isolation. Reference earlier context in this session when relevant."

// ChatMessage is a role/content pair sent to the AI provider, mirroring the
// standard chat-completions message shape ("system" | "user" | "assistant").
type ChatMessage struct {
	Role    string
	Content string
}

type AIChatUsecase interface {
	// SendMessage saves the user's message, loads recent session history,
	// gets a context-aware reply from the AI provider, saves that reply,
	// and returns both the reply text and the session it was saved under.
	// Pass uuid.Nil for sessionID to have a new session auto-created and
	// auto-titled from this message.
	SendMessage(ctx context.Context, userID uuid.UUID, sessionID uuid.UUID, message string) (reply string, resolvedSessionID uuid.UUID, err error)
}

// AIProvider generates a reply given a full conversation, ordered oldest
// first, with the system prompt as the first entry and the latest user
// message as the last entry.
type AIProvider interface {
	GenerateReply(ctx context.Context, messages []ChatMessage) (string, error)
}

type aiChatUsecase struct {
	chatRepo       repository.AIChatRepository
	sessionRepo    repository.ChatSessionRepository
	provider       AIProvider
	subscriptionUC SubscriptionUsecase
}

func NewAIChatUsecase(
	chatRepo repository.AIChatRepository,
	sessionRepo repository.ChatSessionRepository,
	provider AIProvider,
	subscriptionUC SubscriptionUsecase,
) AIChatUsecase {
	return &aiChatUsecase{
		chatRepo:       chatRepo,
		sessionRepo:    sessionRepo,
		provider:       provider,
		subscriptionUC: subscriptionUC,
	}
}

func (uc *aiChatUsecase) SendMessage(ctx context.Context, userID uuid.UUID, sessionID uuid.UUID, message string) (string, uuid.UUID, error) {
	if sessionID == uuid.Nil {
		session := &entity.ChatSession{
			UserID: userID.String(),
			Title:  autoTitleFromMessage(message),
		}
		if err := uc.sessionRepo.Create(ctx, session); err != nil {
			return "", uuid.Nil, fmt.Errorf("create session: %w", err)
		}
		parsed, err := uuid.Parse(session.ID)
		if err != nil {
			return "", uuid.Nil, fmt.Errorf("parse new session id: %w", err)
		}
		sessionID = parsed
	}

	userMsg := &entity.AIChat{UserID: userID.String(), SessionID: sessionID.String(), Role: "user", Message: message}
	if err := uc.chatRepo.Save(ctx, userMsg); err != nil {
		return "", uuid.Nil, fmt.Errorf("save user message: %w", err)
	}

	// Load recent history (already includes the message just saved above,
	// since it was persisted before this read) trimmed to the most recent
	// maxHistoryMessages entries, oldest first.
	history, err := uc.chatRepo.ListRecentBySession(ctx, sessionID, maxHistoryMessages)
	if err != nil {
		return "", uuid.Nil, fmt.Errorf("load session history: %w", err)
	}

	conversation := buildConversation(history)

	// Provider call: any failure here (500/502/503, timeout, network error)
	// falls into this err branch and must NOT consume the user's quota.
	reply, err := uc.provider.GenerateReply(ctx, conversation)
	if err != nil {
		log.Printf("AI provider error: %v", err)
		return "", uuid.Nil, apperror.ErrAIProviderFailed
	}

	assistantMsg := &entity.AIChat{UserID: userID.String(), SessionID: sessionID.String(), Role: "assistant", Message: reply}
	if err := uc.chatRepo.Save(ctx, assistantMsg); err != nil {
		return "", uuid.Nil, fmt.Errorf("save assistant message: %w", err)
	}

	// Only record usage/touch after a fully successful round trip. If
	// either of these best-effort calls fails, the reply is still returned.
	_ = uc.subscriptionUC.RecordDailyUsage(ctx, userID, "ai_chat_daily_limit")
	_ = uc.sessionRepo.Touch(ctx, sessionID)

	return reply, sessionID, nil
}

// buildConversation converts stored chat history into the provider's
// message format, prefixed with the system prompt. history is expected
// oldest-first and already capped to maxHistoryMessages by the repository.
func buildConversation(history []entity.AIChat) []ChatMessage {
	messages := make([]ChatMessage, 0, len(history)+1)
	messages = append(messages, ChatMessage{Role: "system", Content: systemPrompt})
	for _, h := range history {
		messages = append(messages, ChatMessage{Role: h.Role, Content: h.Message})
	}
	return messages
}

// autoTitleFromMessage derives a session title from the first user message.
func autoTitleFromMessage(message string) string {
	trimmed := strings.TrimSpace(message)
	if trimmed == "" {
		return "New Chat"
	}
	const maxLen = 50
	runes := []rune(trimmed)
	if len(runes) > maxLen {
		return string(runes[:maxLen]) + "..."
	}
	return trimmed
}