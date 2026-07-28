package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"ai-mentor-backend/internal/delivery/http/middleware"
)

// currentUserID returns the authenticated user's id (set by JWTAuth) as a
// string, ready to pass through DTOs/usecases that model ids as strings.
func currentUserID(c *gin.Context) string {
	id, ok := c.Get(middleware.ContextUserIDKey)
	if !ok {
		return ""
	}
	uid, ok := id.(uuid.UUID)
	if !ok {
		return ""
	}
	return uid.String()
}