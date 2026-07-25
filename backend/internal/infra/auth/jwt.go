package auth

import (
    "time"

    "github.com/golang-jwt/jwt/v5"
)

// GenerateJWT creates a signed JWT for the given user ID and role.
func GenerateJWT(userID string, role string, secret string, ttl time.Duration) (string, error) {
    claims := jwt.MapClaims{
        "sub":  userID,
        "role": role,
        "iat":  time.Now().Unix(),
        "exp":  time.Now().Add(ttl).Unix(),
    }
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(secret))
}
