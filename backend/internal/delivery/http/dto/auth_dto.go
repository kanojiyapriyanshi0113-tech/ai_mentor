package dto

// RegisterRequest is the payload for POST /api/auth/register.
type RegisterRequest struct {
    Name     string `json:"name" validate:"required,min=2,max=100"`
    Email    string `json:"email" validate:"required,email"`
    Password string `json:"password" validate:"required,min=8"`
}

// AuthResponse is returned by Register and Login.
type AuthResponse struct {
    Token string     `json:"token"`
    User  UserBrief  `json:"user"`
}

// UserBrief is a lightweight user payload embedded in auth responses.
type UserBrief struct {
    ID             string `json:"id"`
    Name           string `json:"name"`
    Email          string `json:"email"`
    Premium        bool   `json:"premium"`
    TrialStartDate string `json:"trial_start_date"`
    TrialEndDate   string `json:"trial_end_date"`
}

// LoginRequest is the payload for POST /api/auth/login.
type LoginRequest struct {
    Email    string `json:"email" validate:"required,email"`
    Password string `json:"password" validate:"required"`
}
