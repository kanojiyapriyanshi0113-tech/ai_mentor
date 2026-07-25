package entity

import (
    "time"

    "github.com/google/uuid"
)

type Subscription struct {
    ID        uuid.UUID
    UserID    uuid.UUID
    PlanID    int
    Status    string
    StartedAt time.Time
    ExpiresAt time.Time
}

func (s *Subscription) Active() bool {
    return s.Status == "active" && time.Now().Before(s.ExpiresAt)
}