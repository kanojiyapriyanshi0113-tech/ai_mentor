package repository

import (
"context"

"github.com/google/uuid"
)

// UserProgressRepository tracks distinct content items a user has completed
// (chapters), watched (videos), or opened (notes), keyed by ordinal position.
// Marking the same resource complete twice does not double-count.
type UserProgressRepository interface {
MarkComplete(ctx context.Context, userID uuid.UUID, featureKey string, ordinal int) error
CountCompleted(ctx context.Context, userID uuid.UUID, featureKey string) (int, error)
}
