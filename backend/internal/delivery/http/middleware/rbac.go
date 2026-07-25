package middleware

import (
    "net/http"

    "github.com/gin-gonic/gin"

    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/entity"
)

// requireRole aborts the request with 403 unless the authenticated user's
// role (set by JWTAuth) matches one of the allowed roles.
func requireRole(allowed ...entity.Role) gin.HandlerFunc {
    return func(c *gin.Context) {
        roleVal, exists := c.Get(ContextUserRoleKey)
        if !exists {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "Missing authentication")
            c.Abort()
            return
        }

        role := entity.Role(roleVal.(string))
        for _, r := range allowed {
            if role == r {
                c.Next()
                return
            }
        }

        response.Error(c, http.StatusForbidden, "FORBIDDEN", "You do not have permission to perform this action")
        c.Abort()
    }
}

// RequireAdmin restricts a route to admin users only.
func RequireAdmin() gin.HandlerFunc {
    return requireRole(entity.RoleAdmin)
}

// RequireTeacher restricts a route to admin and teacher users (content management).
func RequireTeacher() gin.HandlerFunc {
    return requireRole(entity.RoleAdmin, entity.RoleTeacher)
}

// RequireStudent restricts a route to admin, teacher, and student users (learning access).
func RequireStudent() gin.HandlerFunc {
    return requireRole(entity.RoleAdmin, entity.RoleTeacher, entity.RoleStudent)
}
