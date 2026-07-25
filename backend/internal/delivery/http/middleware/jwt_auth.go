package middleware

import (
    "net/http"
    "strings"

    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"
    "github.com/google/uuid"

    "ai-mentor-backend/internal/delivery/http/response"
)

// ContextUserIDKey is the gin.Context key used to store the authenticated user's UUID.
const ContextUserIDKey = "userID"

// ContextUserRoleKey is the gin.Context key used to store the authenticated user's role.
const ContextUserRoleKey = "userRole"

// JWTAuth returns a gin middleware that validates a Bearer JWT and injects the
// user ID and role into context.
func JWTAuth(jwtSecret string) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "Missing or invalid Authorization header")
            c.Abort()
            return
        }

        tokenString := strings.TrimPrefix(authHeader, "Bearer ")

        token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
            if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
                return nil, jwt.ErrSignatureInvalid
            }
            return []byte(jwtSecret), nil
        })
        if err != nil || !token.Valid {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "Invalid or expired token")
            c.Abort()
            return
        }

        claims, ok := token.Claims.(jwt.MapClaims)
        if !ok {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "Invalid token claims")
            c.Abort()
            return
        }

        sub, ok := claims["sub"].(string)
        if !ok {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "Invalid token subject")
            c.Abort()
            return
        }

        userID, err := uuid.Parse(sub)
        if err != nil {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "Invalid user id in token")
            c.Abort()
            return
        }

        role, _ := claims["role"].(string)
        if role == "" {
            role = "student"
        }

        c.Set(ContextUserIDKey, userID)
        c.Set(ContextUserRoleKey, role)
        c.Next()
    }
}
