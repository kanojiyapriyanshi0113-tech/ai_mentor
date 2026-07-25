package http

import (
    "github.com/gin-gonic/gin"

    "ai-mentor-backend/internal/delivery/http/handler"
)

// RegisterAuthRoutes wires Register and Login endpoints onto the given
// router group. Other auth routes (forgot-password, google) are
// registered separately in their own slices.
func RegisterAuthRoutes(rg *gin.RouterGroup, authHandler *handler.AuthHandler) {
    auth := rg.Group("/auth")
    {
        auth.POST("/register", authHandler.Register)
        auth.POST("/login", authHandler.Login)
    }
}
