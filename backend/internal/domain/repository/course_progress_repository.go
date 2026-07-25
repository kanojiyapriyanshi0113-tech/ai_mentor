package repository

import (
    "context"
    "time"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

// CourseProgressRepository tracks per-user lecture completion and derives
// chapter/batch level rollups from it.
type CourseProgressRepository interface {
    MarkLectureComplete(ctx context.Context, userID, lectureID uuid.UUID) error
    CountLectures(ctx context.Context, userID, batchID uuid.UUID) (completed int, total int, err error)
    ListChapterCompletion(ctx context.Context, userID, batchID uuid.UUID) ([]entity.ChapterCompletion, error)
    GetLastWatchedLecture(ctx context.Context, userID, batchID uuid.UUID) (*entity.LectureRef, *time.Time, error)
    GetContinueLearningLecture(ctx context.Context, userID, batchID uuid.UUID) (*entity.LectureRef, error)
}
