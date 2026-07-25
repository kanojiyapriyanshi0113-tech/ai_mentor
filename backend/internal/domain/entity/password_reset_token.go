package entity

import "time"

// PasswordResetToken represents a single-use reset token.
type PasswordResetToken struct {
    ID        string
    UserID    string
    TokenHash string
    ExpiresAt time.Time
    Used      bool
    CreatedAt time.Time
}
