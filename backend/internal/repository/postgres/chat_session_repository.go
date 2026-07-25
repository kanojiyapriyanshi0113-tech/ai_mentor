package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/entity"
)

type chatSessionRepository struct {
	db *pgxpool.Pool
}

func NewChatSessionRepository(db *pgxpool.Pool) *chatSessionRepository {
	return &chatSessionRepository{db: db}
}

func (r *chatSessionRepository) Create(ctx context.Context, session *entity.ChatSession) error {
	const q = `
		INSERT INTO chat_sessions (user_id, title)
		VALUES ($1, $2)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, q, session.UserID, session.Title).
		Scan(&session.ID, &session.CreatedAt, &session.UpdatedAt)
	if err != nil {
		return fmt.Errorf("insert chat session: %w", err)
	}
	return nil
}

func (r *chatSessionRepository) Rename(ctx context.Context, sessionID, userID uuid.UUID, title string) error {
	const q = `
		UPDATE chat_sessions
		SET title = $1, updated_at = now()
		WHERE id = $2 AND user_id = $3
	`
	tag, err := r.db.Exec(ctx, q, title, sessionID, userID)
	if err != nil {
		return fmt.Errorf("rename chat session: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

func (r *chatSessionRepository) Delete(ctx context.Context, sessionID, userID uuid.UUID) error {
	const q = `DELETE FROM chat_sessions WHERE id = $1 AND user_id = $2`
	tag, err := r.db.Exec(ctx, q, sessionID, userID)
	if err != nil {
		return fmt.Errorf("delete chat session: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

func (r *chatSessionRepository) ListByUser(ctx context.Context, userID uuid.UUID) ([]entity.ChatSession, error) {
	const q = `
		SELECT id, user_id, title, created_at, updated_at
		FROM chat_sessions
		WHERE user_id = $1
		ORDER BY updated_at DESC
	`
	rows, err := r.db.Query(ctx, q, userID)
	if err != nil {
		return nil, fmt.Errorf("list chat sessions: %w", err)
	}
	defer rows.Close()

	var sessions []entity.ChatSession
	for rows.Next() {
		var s entity.ChatSession
		if err := rows.Scan(&s.ID, &s.UserID, &s.Title, &s.CreatedAt, &s.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan chat session: %w", err)
		}
		sessions = append(sessions, s)
	}
	return sessions, nil
}

func (r *chatSessionRepository) FindByID(ctx context.Context, sessionID, userID uuid.UUID) (*entity.ChatSession, error) {
	const q = `
		SELECT id, user_id, title, created_at, updated_at
		FROM chat_sessions
		WHERE id = $1 AND user_id = $2
	`
	var s entity.ChatSession
	err := r.db.QueryRow(ctx, q, sessionID, userID).
		Scan(&s.ID, &s.UserID, &s.Title, &s.CreatedAt, &s.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("find chat session: %w", err)
	}
	return &s, nil
}

func (r *chatSessionRepository) Touch(ctx context.Context, sessionID uuid.UUID) error {
	const q = `UPDATE chat_sessions SET updated_at = now() WHERE id = $1`
	_, err := r.db.Exec(ctx, q, sessionID)
	if err != nil {
		return fmt.Errorf("touch chat session: %w", err)
	}
	return nil
}