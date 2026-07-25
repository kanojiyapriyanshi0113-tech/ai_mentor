package entity

import (
    "time"

    "github.com/google/uuid"
)

// User represents a registered user of the platform.
type User struct {
    ID             uuid.UUID
    Name           string
    Email          string
    PasswordHash   string
    GoogleID       string
    IsVerified     bool
    Premium        bool
    Role           Role
    TrialStartDate time.Time
    TrialEndDate   time.Time
    CreatedAt      time.Time
    UpdatedAt      time.Time
}

// TrialActive returns whether the user's free trial is currently active.
func (u *User) TrialActive() bool {
    if u.Premium {
        return true
    }
    return time.Now().Before(u.TrialEndDate)
}
