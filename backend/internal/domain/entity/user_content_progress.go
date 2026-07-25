package entity

import (
"time"

"github.com/google/uuid"
)

type UserContentProgress struct {
ID              uuid.UUID
UserID          uuid.UUID
FeatureKey      string
ResourceOrdinal int
CompletedAt     time.Time
}
