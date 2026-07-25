package response

import "github.com/gin-gonic/gin"

// APIResponse is the standard envelope for all API responses.
type APIResponse struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
    Error   *APIError   `json:"error,omitempty"`
}

// APIError represents a structured error payload.
type APIError struct {
    Code    string `json:"code"`
    Message string `json:"message"`
}

// Success sends a 2xx JSON response with the standard envelope.
func Success(c *gin.Context, statusCode int, data interface{}, message string) {
    c.JSON(statusCode, APIResponse{
        Success: true,
        Message: message,
        Data:    data,
    })
}

// Error sends an error JSON response with the standard envelope.
func Error(c *gin.Context, statusCode int, code string, message string) {
    c.JSON(statusCode, APIResponse{
        Success: false,
        Error: &APIError{
            Code:    code,
            Message: message,
        },
    })
}
