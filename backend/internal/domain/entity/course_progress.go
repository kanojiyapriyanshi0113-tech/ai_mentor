package entity

import (
    "time"

    "github.com/google/uuid"
)

// LectureProgress is a single completed-lecture record for a user.
type LectureProgress struct {
    ID          uuid.UUID
    UserID      uuid.UUID
    LectureID   uuid.UUID
    ChapterID   uuid.UUID
    SubjectID   uuid.UUID
    BatchID     uuid.UUID
    CompletedAt time.Time
}

// ChapterCompletion holds lecture completion counts for one chapter.
type ChapterCompletion struct {
    ChapterID         uuid.UUID
    TotalLectures     int
    CompletedLectures int
}

// IsComplete reports whether every lecture in the chapter is done.
func (c ChapterCompletion) IsComplete() bool {
    return c.TotalLectures > 0 && c.CompletedLectures == c.TotalLectures
}

// LectureRef is a lightweight lecture pointer with chapter context, used
// for "last watched" and "continue learning" lookups.
type LectureRef struct {
    LectureID    uuid.UUID
    LectureTitle string
    ChapterID    uuid.UUID
    ChapterTitle string
}
