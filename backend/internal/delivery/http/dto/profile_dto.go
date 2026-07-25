package dto

import "time"

// ProfileResponse is returned by GET /api/profile.
type ProfileResponse struct {
    ID             string    `json:"id"`
    Name           string    `json:"name"`
    Email          string    `json:"email"`
    Premium        bool      `json:"premium"`
    TrialActive    bool      `json:"trial_active"`
    TrialStartDate time.Time `json:"trial_start_date"`
    TrialEndDate   time.Time `json:"trial_end_date"`
    CreatedAt      time.Time `json:"created_at"`
}

// UpdateProfileRequest is the payload for PUT /api/profile.
type UpdateProfileRequest struct {
    Name string `json:"name" validate:"required,min=2,max=100"`
}
