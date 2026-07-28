package entity

import (
	"time"

	"github.com/google/uuid"
)

// UserNotificationType categorizes a recipient-scoped notification.
type UserNotificationType string

const (
	UserNotificationGeneral     UserNotificationType = "general"
	UserNotificationBatch       UserNotificationType = "batch"
	UserNotificationPayment     UserNotificationType = "payment"
	UserNotificationAssignment  UserNotificationType = "assignment"
	UserNotificationLiveClass   UserNotificationType = "live_class"
	UserNotificationApplication UserNotificationType = "application"
	UserNotificationSystem      UserNotificationType = "system"
)

// UserNotification is a single recipient-scoped, read-tracked notification.
// It complements the existing Notification type (a batch-wide broadcast) by
// giving every student/teacher/admin an individual feed with read state —
// either fanned out from a batch Notification or created directly (payment
// receipts, application status changes, system alerts, etc).
type UserNotification struct {
	ID             uuid.UUID
	RecipientID    uuid.UUID
	SenderID       *uuid.UUID
	NotificationID *uuid.UUID
	Type           UserNotificationType
	Title          string
	Message        string
	IsRead         bool
	ReadAt         *time.Time
	CreatedAt      time.Time
	UpdatedAt      time.Time
	DeletedAt      *time.Time
}
