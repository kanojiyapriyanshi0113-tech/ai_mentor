package repository

import (
	"context"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/entity"
)

type CourseRepository interface {
	ListBatches(ctx context.Context, examID int) ([]entity.Batch, error)
	GetBatchByID(ctx context.Context, batchID uuid.UUID) (*entity.Batch, error)
	ListSubjectsByBatch(ctx context.Context, batchID uuid.UUID) ([]entity.Subject, error)
	ListChaptersBySubject(ctx context.Context, subjectID uuid.UUID) ([]entity.Chapter, error)
	ListLecturesByChapter(ctx context.Context, chapterID uuid.UUID) ([]entity.Lecture, error)
}
