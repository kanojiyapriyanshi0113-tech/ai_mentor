package entity

import "time"

// ApplicationStatus is the review state of a "Become a Teacher" application.
type ApplicationStatus string

const (
	ApplicationPending          ApplicationStatus = "pending"
	ApplicationApproved         ApplicationStatus = "approved"
	ApplicationRejected         ApplicationStatus = "rejected"
	ApplicationChangesRequested ApplicationStatus = "changes_requested"
)

// TeacherApplication is a student's submission to become a teacher.
type TeacherApplication struct {
	ID              string
	UserID          string
	FullName        string
	Email           string
	Phone           string
	Qualification   string
	ExperienceYears int
	ExamExpertise   string
	Subjects        string
	About           string
	ResumeURL       string
	DegreeURL       string
	GovtIDURL       string
	PhotoURL        string
	DemoVideoURL    string
	ExpectedSalary  int
	Status          ApplicationStatus
	AdminNote       string
	ReviewedBy      string
	ReviewedAt      *time.Time
	CreatedAt       time.Time
	UpdatedAt       time.Time
}