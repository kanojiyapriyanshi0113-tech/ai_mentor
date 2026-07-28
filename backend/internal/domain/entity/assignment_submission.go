package entity

import (
	"time"

	"github.com/google/uuid"
)

// SubmissionStatus is the grading state of an assignment submission.
type SubmissionStatus string

const (
	SubmissionSubmitted         SubmissionStatus = "submitted"
	SubmissionLate              SubmissionStatus = "late"
	SubmissionGraded            SubmissionStatus = "graded"
	SubmissionResubmitRequested SubmissionStatus = "resubmit_requested"
)

// AssignmentSubmission is a student's response to a teacher-created Assignment.
type AssignmentSubmission struct {
	ID              uuid.UUID
	AssignmentID    uuid.UUID
	StudentID       uuid.UUID
	FileURL         string
	SubmissionText  string
	MarksObtained   *int
	Feedback        string
	Status          SubmissionStatus
	SubmittedAt     time.Time
	GradedAt        *time.Time
	GradedBy        *uuid.UUID
	CreatedAt       time.Time
	UpdatedAt       time.Time
	DeletedAt       *time.Time
}
