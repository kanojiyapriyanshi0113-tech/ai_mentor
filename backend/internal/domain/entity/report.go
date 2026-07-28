package entity

import (
	"time"

	"github.com/google/uuid"
)

// ReportType identifies which admin report a Report row was generated for.
type ReportType string

const (
	ReportRevenue  ReportType = "revenue"
	ReportStudents ReportType = "students"
	ReportCourses  ReportType = "courses"
	ReportTeachers ReportType = "teachers"
	ReportCustom   ReportType = "custom"
)

// ReportStatus is the generation state of a Report job.
type ReportStatus string

const (
	ReportPending    ReportStatus = "pending"
	ReportProcessing ReportStatus = "processing"
	ReportCompleted  ReportStatus = "completed"
	ReportFailed     ReportStatus = "failed"
)

// Report is a single generated/exported admin report (e.g. a revenue or
// students CSV export), tracked as a job with filters and an output file.
type Report struct {
	ID          uuid.UUID
	Type        ReportType
	Title       string
	Filters     map[string]any
	FileURL     string
	Status      ReportStatus
	GeneratedBy *uuid.UUID
	GeneratedAt *time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
	DeletedAt   *time.Time
}
