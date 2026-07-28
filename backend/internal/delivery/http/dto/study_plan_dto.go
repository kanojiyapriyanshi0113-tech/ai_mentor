package dto

import "time"

// StudyPlanResponse represents a single planner entry in list/detail views.
type StudyPlanResponse struct {
	ID          string    `json:"id"`
	Date        time.Time `json:"date"`
	Goal        string    `json:"goal"`
	IsCompleted bool      `json:"is_completed"`
	CreatedAt   time.Time `json:"created_at"`
}

// CreateStudyPlanRequest is the payload for POST /api/planner/plans.
//
// Date must be RFC3339 with a timezone offset (e.g. "2026-07-28T00:00:00+05:30").
// Go's time.Time JSON unmarshal requires an offset — a bare date like
// "2026-07-28" will fail to bind, so the Flutter side must send
// DateTime.toIso8601String() on a value that carries an offset, not a UTC-Z
// midnight-only string.
type CreateStudyPlanRequest struct {
	Date        time.Time `json:"date" validate:"required"`
	Goal        string    `json:"goal" validate:"required,min=1,max=500"`
	IsCompleted bool      `json:"is_completed"`
}

// UpdateStudyPlanRequest is the payload for PUT /api/planner/plans/:id.
type UpdateStudyPlanRequest struct {
	Date        time.Time `json:"date" validate:"required"`
	Goal        string    `json:"goal" validate:"required,min=1,max=500"`
	IsCompleted bool      `json:"is_completed"`
}