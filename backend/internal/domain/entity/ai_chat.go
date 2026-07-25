package entity

import "time"

// AIChat represents a single message in a user's AI chat history.
type AIChat struct {
	ID        string
	UserID    string
	SessionID string // empty string for messages sent before sessions existed
	Role      string // "user" or "assistant"
	Message   string
	CreatedAt time.Time
}