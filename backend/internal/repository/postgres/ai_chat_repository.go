package postgres

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/entity"
)

type aiChatRepository struct {
	db *pgxpool.Pool
}

func NewAIChatRepository(db *pgxpool.Pool) *aiChatRepository {
	return &aiChatRepository{db: db}
}

func (r *aiChatRepository) Save(ctx context.Context, chat *entity.AIChat) error {
	const q = `
		INSERT INTO ai_chats (user_id, session_id, role, message)
		VALUES ($1, NULLIF($2, '')::uuid, $3, $4)
	`
	_, err := r.db.Exec(ctx, q, chat.UserID, chat.SessionID, chat.Role, chat.Message)
	if err != nil {
		return fmt.Errorf("insert ai chat: %w", err)
	}
	return nil
}

func (r *aiChatRepository) ListByUser(ctx context.Context, userID uuid.UUID, limit int) ([]entity.AIChat, error) {
	const q = `
		SELECT id, user_id, COALESCE(session_id::text, ''), role, message, created_at
		FROM ai_chats
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, q, userID, limit)
	if err != nil {
		return nil, fmt.Errorf("list ai chats: %w", err)
	}
	defer rows.Close()

	var chats []entity.AIChat
	for rows.Next() {
		var c entity.AIChat
		if err := rows.Scan(&c.ID, &c.UserID, &c.SessionID, &c.Role, &c.Message, &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan ai chat: %w", err)
		}
		chats = append(chats, c)
	}
	return chats, nil
}

func (r *aiChatRepository) ListBySession(ctx context.Context, sessionID uuid.UUID, limit int) ([]entity.AIChat, error) {
	const q = `
		SELECT id, user_id, COALESCE(session_id::text, ''), role, message, created_at
		FROM ai_chats
		WHERE session_id = $1
		ORDER BY created_at ASC
		LIMIT $2
	`
	rows, err := r.db.Query(ctx, q, sessionID, limit)
	if err != nil {
		return nil, fmt.Errorf("list ai chats by session: %w", err)
	}
	defer rows.Close()

	var chats []entity.AIChat
	for rows.Next() {
		var c entity.AIChat
		if err := rows.Scan(&c.ID, &c.UserID, &c.SessionID, &c.Role, &c.Message, &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan ai chat: %w", err)
		}
		chats = append(chats, c)
	}
	return chats, nil
}

// ListRecentBySession fetches the newest `limit` rows (DESC + LIMIT, so the
// index is used efficiently even on long sessions) then re-orders them
// ascending in the outer query so callers always get chronological order.
func (r *aiChatRepository) ListRecentBySession(ctx context.Context, sessionID uuid.UUID, limit int) ([]entity.AIChat, error) {
	const q = `
		SELECT id, user_id, session_id, role, message, created_at FROM (
			SELECT id, user_id, COALESCE(session_id::text, '') AS session_id, role, message, created_at
			FROM ai_chats
			WHERE session_id = $1
			ORDER BY created_at DESC
			LIMIT $2
		) recent
		ORDER BY created_at ASC
	`
	rows, err := r.db.Query(ctx, q, sessionID, limit)
	if err != nil {
		return nil, fmt.Errorf("list recent ai chats by session: %w", err)
	}
	defer rows.Close()

	var chats []entity.AIChat
	for rows.Next() {
		var c entity.AIChat
		if err := rows.Scan(&c.ID, &c.UserID, &c.SessionID, &c.Role, &c.Message, &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan ai chat: %w", err)
		}
		chats = append(chats, c)
	}
	return chats, nil
}