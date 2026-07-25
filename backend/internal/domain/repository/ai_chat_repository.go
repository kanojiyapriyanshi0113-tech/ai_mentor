package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

type AIChatRepository interface {
	Save(ctx context.Context, chat *entity.AIChat) error
	ListByUser(ctx context.Context, userID uuid.UUID, limit int) ([]entity.AIChat, error)
	// ListBySession returns every message in a session, oldest first —
	// used to render a full chat thread (e.g. GET /chat/session/:id).
	ListBySession(ctx context.Context, sessionID uuid.UUID, limit int) ([]entity.AIChat, error)
	// ListRecentBySession returns the most recent `limit` messages in a
	// session, but still ordered oldest-first — used to build AI provider
	// context without pulling entire (potentially long) history.
	ListRecentBySession(ctx context.Context, sessionID uuid.UUID, limit int) ([]entity.AIChat, error)
}