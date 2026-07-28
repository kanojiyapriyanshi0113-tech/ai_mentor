package entity

import "time"

// Batch represents a course batch tied to a specific exam.
type Batch struct {
ID          string
ExamID      int
Title       string
Description string
Thumbnail   string
IsActive    bool
TeacherID   string
CreatedAt   time.Time
}

// TeacherStudent is a lightweight view of a student engaged with one of a
// teacher's batches, used for the "My Students" screen.
type TeacherStudent struct {
	ID          string
	Name        string
	Email       string
	BatchTitles []string
	LastActive  time.Time
}

// Subject represents a subject within a batch.
type Subject struct {
ID           string
BatchID      string
Name         string
Icon         string
DisplayOrder int
}

// Chapter represents a chapter within a subject.
type Chapter struct {
ID           string
SubjectID    string
Title        string
Description  string
DisplayOrder int
}

// Lecture represents a single video lecture within a chapter.
type Lecture struct {
ID              string
ChapterID       string
Title           string
Description     string
DurationMinutes int
VideoURL        string
IsPreview       bool
DisplayOrder    int
}