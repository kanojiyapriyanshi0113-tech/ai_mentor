package usecase

import (
    "context"
    "fmt"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/repository"
)

// LectureSummary is a lightweight lecture reference returned in progress responses.
type LectureSummary struct {
    LectureID    uuid.UUID
    LectureTitle string
    ChapterID    uuid.UUID
    ChapterTitle string
}

// BatchProgress is the aggregated progress view for a user within one batch.
type BatchProgress struct {
    CompletedLectures int
    TotalLectures     int
    CompletedChapters int
    TotalChapters     int
    ProgressPercent   float64
    LastWatched       *LectureSummary
    ContinueLearning  *LectureSummary
}

type CourseProgressUsecase interface {
    CompleteLecture(ctx context.Context, userID, lectureID uuid.UUID) error
    GetBatchProgress(ctx context.Context, userID, batchID uuid.UUID) (*BatchProgress, error)
}

type courseProgressUsecase struct {
    progressRepo repository.CourseProgressRepository
}

func NewCourseProgressUsecase(progressRepo repository.CourseProgressRepository) CourseProgressUsecase {
    return &courseProgressUsecase{progressRepo: progressRepo}
}

func (uc *courseProgressUsecase) CompleteLecture(ctx context.Context, userID, lectureID uuid.UUID) error {
    if err := uc.progressRepo.MarkLectureComplete(ctx, userID, lectureID); err != nil {
        return fmt.Errorf("complete lecture: %w", err)
    }
    return nil
}

func (uc *courseProgressUsecase) GetBatchProgress(ctx context.Context, userID, batchID uuid.UUID) (*BatchProgress, error) {
    completedLectures, totalLectures, err := uc.progressRepo.CountLectures(ctx, userID, batchID)
    if err != nil {
        return nil, fmt.Errorf("count lectures: %w", err)
    }

    chapters, err := uc.progressRepo.ListChapterCompletion(ctx, userID, batchID)
    if err != nil {
        return nil, fmt.Errorf("list chapter completion: %w", err)
    }
    completedChapters := 0
    for _, ch := range chapters {
        if ch.IsComplete() {
            completedChapters++
        }
    }

    lastWatchedRef, _, err := uc.progressRepo.GetLastWatchedLecture(ctx, userID, batchID)
    if err != nil {
        return nil, fmt.Errorf("get last watched lecture: %w", err)
    }

    continueRef, err := uc.progressRepo.GetContinueLearningLecture(ctx, userID, batchID)
    if err != nil {
        return nil, fmt.Errorf("get continue learning lecture: %w", err)
    }

    var progressPercent float64
    if totalLectures > 0 {
        progressPercent = (float64(completedLectures) / float64(totalLectures)) * 100
    }

    bp := &BatchProgress{
        CompletedLectures: completedLectures,
        TotalLectures:     totalLectures,
        CompletedChapters: completedChapters,
        TotalChapters:     len(chapters),
        ProgressPercent:   progressPercent,
    }
    if lastWatchedRef != nil {
        bp.LastWatched = &LectureSummary{
            LectureID:    lastWatchedRef.LectureID,
            LectureTitle: lastWatchedRef.LectureTitle,
            ChapterID:    lastWatchedRef.ChapterID,
            ChapterTitle: lastWatchedRef.ChapterTitle,
        }
    }
    if continueRef != nil {
        bp.ContinueLearning = &LectureSummary{
            LectureID:    continueRef.LectureID,
            LectureTitle: continueRef.LectureTitle,
            ChapterID:    continueRef.ChapterID,
            ChapterTitle: continueRef.ChapterTitle,
        }
    }
    return bp, nil
}
