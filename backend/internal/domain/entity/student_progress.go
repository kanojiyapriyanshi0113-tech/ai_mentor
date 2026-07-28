package entity

import (
	"time"

	"github.com/google/uuid"
)

// StudentProgress is an aggregate rollup of a student's completion within a
// batch, optionally scoped to one subject (SubjectID nil means the row is
// the overall batch-level rollup). Built from the finer-grained
// LectureProgress records; this is what progress dashboards read.
type StudentProgress struct {
	ID                uuid.UUID
	StudentID         uuid.UUID
	BatchID           uuid.UUID
	SubjectID         *uuid.UUID
	TotalLectures     int
	CompletedLectures int
	ProgressPercent   float64
	StreakDays        int
	LastActivityAt    *time.Time
	CreatedAt         time.Time
	UpdatedAt         time.Time
	DeletedAt         *time.Time
}
