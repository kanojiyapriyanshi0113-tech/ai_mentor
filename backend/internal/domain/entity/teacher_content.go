package entity

import "time"

// PDF represents a downloadable document attached to a chapter.
type PDF struct {
    ID           string
    ChapterID    string
    Title        string
    FileURL      string
    DisplayOrder int
    IsActive     bool
    CreatedAt    time.Time
    UpdatedAt    time.Time
}

// MockTest represents a full/sectional mock test within a batch.
type MockTest struct {
    ID              string
    BatchID         string
    Title           string
    DurationMinutes int
    TotalQuestions  int
    IsActive        bool
    CreatedAt       time.Time
    UpdatedAt       time.Time
}

// PYQ represents a previous-year-question paper within a batch.
type PYQ struct {
    ID         string
    BatchID    string
    ExamName   string
    Year       int
    SubjectTag string
    FileURL    string
    IsActive   bool
    CreatedAt  time.Time
    UpdatedAt  time.Time
}

// Assignment represents a task set by a teacher for students of a batch.
type Assignment struct {
    ID          string
    BatchID     string
    Title       string
    Description string
    FileURL     string
    DueAt       *time.Time
    MaxMarks    int
    IsActive    bool
    CreatedAt   time.Time
    UpdatedAt   time.Time
}

// LiveClass represents a scheduled live session for a batch.
type LiveClass struct {
    ID          string
    BatchID     string
    Title       string
    ScheduledAt time.Time
    MeetingURL  string
    IsActive    bool
    CreatedAt   time.Time
    UpdatedAt   time.Time
}

// Notification represents a message broadcast to all students in a batch.
type Notification struct {
    ID        string
    BatchID   string
    SenderID  string
    Title     string
    Message   string
    CreatedAt time.Time
}

// TeacherDashboardStats is the aggregate view for the teacher dashboard.
type TeacherDashboardStats struct {
    TotalStudents       int
    TotalBatches        int
    TotalSubjects       int
    TotalChapters       int
    TotalLectures       int
    TotalPDFs           int
    TotalMockTests      int
    UpcomingLiveClasses []LiveClass
}