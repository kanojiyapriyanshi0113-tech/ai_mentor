package usecase

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

// ChatSessionWithMessages is returned by GetSession — the session's
// metadata plus its full message history in chronological order.
type ChatSessionWithMessages struct {
	Session  entity.ChatSession
	Messages []entity.AIChat
}

type ChatSessionUsecase interface {
	CreateSession(ctx context.Context, userID uuid.UUID, title string) (*entity.ChatSession, error)
	ListSessions(ctx context.Context, userID uuid.UUID) ([]entity.ChatSession, error)
	GetSession(ctx context.Context, userID, sessionID uuid.UUID) (*ChatSessionWithMessages, error)
	RenameSession(ctx context.Context, userID, sessionID uuid.UUID, title string) error
	DeleteSession(ctx context.Context, userID, sessionID uuid.UUID) error
}

type chatSessionUsecase struct {
	sessionRepo repository.ChatSessionRepository
	chatRepo    repository.AIChatRepository
}

func NewChatSessionUsecase(sessionRepo repository.ChatSessionRepository, chatRepo repository.AIChatRepository) ChatSessionUsecase {
	return &chatSessionUsecase{sessionRepo: sessionRepo, chatRepo: chatRepo}
}

func (uc *chatSessionUsecase) CreateSession(ctx context.Context, userID uuid.UUID, title string) (*entity.ChatSession, error) {
	if strings.TrimSpace(title) == "" {
		title = "New Chat"
	}
	session := &entity.ChatSession{UserID: userID.String(), Title: title}
	if err := uc.sessionRepo.Create(ctx, session); err != nil {
		return nil, fmt.Errorf("create session: %w", err)
	}
	return session, nil
}

func (uc *chatSessionUsecase) ListSessions(ctx context.Context, userID uuid.UUID) ([]entity.ChatSession, error) {
	sessions, err := uc.sessionRepo.ListByUser(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("list sessions: %w", err)
	}
	return sessions, nil
}

func (uc *chatSessionUsecase) GetSession(ctx context.Context, userID, sessionID uuid.UUID) (*ChatSessionWithMessages, error) {
	session, err := uc.sessionRepo.FindByID(ctx, sessionID, userID)
	if err != nil {
		return nil, fmt.Errorf("find session: %w", err)
	}
	if session == nil {
		return nil, apperror.ErrChatSessionNotFound
	}

	messages, err := uc.chatRepo.ListBySession(ctx, sessionID, 500)
	if err != nil {
		return nil, fmt.Errorf("list messages: %w", err)
	}

	return &ChatSessionWithMessages{Session: *session, Messages: messages}, nil
}

func (uc *chatSessionUsecase) RenameSession(ctx context.Context, userID, sessionID uuid.UUID, title string) error {
	if strings.TrimSpace(title) == "" {
		return apperror.ErrInvalidChatSessionTitle
	}
	if err := uc.sessionRepo.Rename(ctx, sessionID, userID, title); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return apperror.ErrChatSessionNotFound
		}
		return fmt.Errorf("rename session: %w", err)
	}
	return nil
}

func (uc *chatSessionUsecase) DeleteSession(ctx context.Context, userID, sessionID uuid.UUID) error {
	if err := uc.sessionRepo.Delete(ctx, sessionID, userID); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return apperror.ErrChatSessionNotFound
		}
		return fmt.Errorf("delete session: %w", err)
	}
	return nil
}