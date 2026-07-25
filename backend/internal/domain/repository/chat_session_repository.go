package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

type ChatSessionRepository interface {
	Create(ctx context.Context, session *entity.ChatSession) error
	Rename(ctx context.Context, sessionID, userID uuid.UUID, title string) error
	Delete(ctx context.Context, sessionID, userID uuid.UUID) error
	ListByUser(ctx context.Context, userID uuid.UUID) ([]entity.ChatSession, error)
	FindByID(ctx context.Context, sessionID, userID uuid.UUID) (*entity.ChatSession, error)
	// Touch bumps updated_at so ListByUser (ordered by updated_at DESC)
	// surfaces the most recently active conversation first.
	Touch(ctx context.Context, sessionID uuid.UUID) error
}