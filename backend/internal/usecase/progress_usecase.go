package usecase

import (
"context"

"github.com/google/uuid"

"ai-mentor-backend/internal/domain/repository"
)

type ProgressUsecase interface {
CompleteChapter(ctx context.Context, userID uuid.UUID, chapterNumber int) error
WatchVideo(ctx context.Context, userID uuid.UUID, lectureNumber int) error
OpenNote(ctx context.Context, userID uuid.UUID, noteNumber int) error
}

type progressUsecase struct {
progressRepo repository.UserProgressRepository
}

func NewProgressUsecase(progressRepo repository.UserProgressRepository) ProgressUsecase {
return &progressUsecase{progressRepo: progressRepo}
}

func (uc *progressUsecase) CompleteChapter(ctx context.Context, userID uuid.UUID, chapterNumber int) error {
return uc.progressRepo.MarkComplete(ctx, userID, "max_chapters", chapterNumber)
}

func (uc *progressUsecase) WatchVideo(ctx context.Context, userID uuid.UUID, lectureNumber int) error {
return uc.progressRepo.MarkComplete(ctx, userID, "max_lectures", lectureNumber)
}

func (uc *progressUsecase) OpenNote(ctx context.Context, userID uuid.UUID, noteNumber int) error {
return uc.progressRepo.MarkComplete(ctx, userID, "max_notes", noteNumber)
}
