package entity

import "time"

// ChatSession represents a single conversation thread belonging to a user.
type ChatSession struct {
	ID        string
	UserID    string
	Title     string
	CreatedAt time.Time
	UpdatedAt time.Time
}