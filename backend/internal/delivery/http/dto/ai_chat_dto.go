package dto

import "time"

// AIChatRequest is the payload for POST /api/ai/chat.
// SessionID is optional — omit it to start a new auto-titled session.
type AIChatRequest struct {
	Message   string `json:"message" validate:"required,min=1,max=2000"`
	SessionID string `json:"session_id" validate:"omitempty,uuid"`
}

// AIChatMessage is a single message returned in a response.
type AIChatMessage struct {
	Role      string    `json:"role"`
	Message   string    `json:"message"`
	CreatedAt time.Time `json:"created_at"`
}

// AIChatResponse is returned by POST /api/ai/chat.
type AIChatResponse struct {
	Reply     string `json:"reply"`
	SessionID string `json:"session_id"`
}