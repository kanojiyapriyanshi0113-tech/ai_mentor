package dto

// ForgotPasswordRequest is the payload for POST /api/auth/forgot-password.
type ForgotPasswordRequest struct {
    Email string `json:"email" validate:"required,email"`
}

// ResetPasswordRequest is the payload for POST /api/auth/reset-password.
type ResetPasswordRequest struct {
    Token       string `json:"token" validate:"required"`
    NewPassword string `json:"new_password" validate:"required,min=8"`
}
