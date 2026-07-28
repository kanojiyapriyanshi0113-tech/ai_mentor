package entity

import (
	"time"

	"github.com/google/uuid"
)

// AttendanceStatus records how a student attended a live class.
type AttendanceStatus string

const (
	AttendancePresent AttendanceStatus = "present"
	AttendanceAbsent  AttendanceStatus = "absent"
	AttendanceLate    AttendanceStatus = "late"
	AttendanceExcused AttendanceStatus = "excused"
)

// Attendance is one student's attendance record for one LiveClass.
type Attendance struct {
	ID              uuid.UUID
	LiveClassID     uuid.UUID
	StudentID       uuid.UUID
	Status          AttendanceStatus
	JoinedAt        *time.Time
	LeftAt          *time.Time
	DurationMinutes int
	MarkedBy        *uuid.UUID
	CreatedAt       time.Time
	UpdatedAt       time.Time
	DeletedAt       *time.Time
}
