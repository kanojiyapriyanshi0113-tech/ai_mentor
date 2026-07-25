package dto

import "time"

// ChatSessionResponse represents a single chat session in list/detail views.
type ChatSessionResponse struct {
	ID        string    `json:"id"`
	Title     string    `json:"title"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// CreateChatSessionRequest is the payload for POST /api/chat/session.
// Title is optional — omit it to start with "New Chat", which auto-titles
// once the first message is sent through this session.
type CreateChatSessionRequest struct {
	Title string `json:"title" validate:"omitempty,max=200"`
}

// RenameChatSessionRequest is the payload for PATCH /api/chat/session/:id.
type RenameChatSessionRequest struct {
	Title string `json:"title" validate:"required,min=1,max=200"`
}

// ChatSessionDetailResponse is returned by GET /api/chat/session/:id.
type ChatSessionDetailResponse struct {
	Session  ChatSessionResponse `json:"session"`
	Messages []AIChatMessage     `json:"messages"`
}