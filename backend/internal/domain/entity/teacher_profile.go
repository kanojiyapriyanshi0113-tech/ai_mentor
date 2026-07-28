package entity

import (
	"time"

	"github.com/google/uuid"
)

// TeacherProfileStatus is the visibility/activity state of a teacher profile.
type TeacherProfileStatus string

const (
	TeacherProfileActive     TeacherProfileStatus = "active"
	TeacherProfileInactive   TeacherProfileStatus = "inactive"
	TeacherProfileSuspended  TeacherProfileStatus = "suspended"
)

// IsValid reports whether s is one of the known teacher profile statuses.
func (s TeacherProfileStatus) IsValid() bool {
	switch s {
	case TeacherProfileActive, TeacherProfileInactive, TeacherProfileSuspended:
		return true
	default:
		return false
	}
}

// TeacherProfile holds the extended, editable professional details for a
// user with role "teacher" — one row per teacher, created once their
// TeacherApplication is approved.
type TeacherProfile struct {
	ID               uuid.UUID
	UserID           uuid.UUID
	ApplicationID    *uuid.UUID
	Headline         string
	Bio              string
	Qualification    string
	ExperienceYears  int
	ExamExpertise    string
	Subjects         string
	PhotoURL         string
	Rating           float64
	TotalRatings     int
	Status           TeacherProfileStatus
	ApprovedAt       *time.Time
	CreatedAt        time.Time
	UpdatedAt        time.Time
	DeletedAt        *time.Time
}
