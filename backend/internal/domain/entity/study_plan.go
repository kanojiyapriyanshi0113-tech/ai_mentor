package entity

import "time"

// StudyPlan represents a single AI Planner entry belonging to a user —
// a goal for a specific date, with a completion flag.
type StudyPlan struct {
	ID          string
	UserID      string
	Date        time.Time
	Goal        string
	IsCompleted bool
	CreatedAt   time.Time
}