package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

type CourseUsecase interface {
	ListBatches(ctx context.Context, userID uuid.UUID) ([]entity.Batch, error)
	GetBatch(ctx context.Context, batchID uuid.UUID) (*entity.Batch, error)
	ListSubjects(ctx context.Context, batchID uuid.UUID) ([]entity.Subject, error)
	ListChapters(ctx context.Context, subjectID uuid.UUID) ([]entity.Chapter, error)
	ListLectures(ctx context.Context, chapterID uuid.UUID) ([]entity.Lecture, error)
}

type courseUsecase struct {
	courseRepo repository.CourseRepository
	examRepo   repository.ExamRepository
}

func NewCourseUsecase(courseRepo repository.CourseRepository, examRepo repository.ExamRepository) CourseUsecase {
	return &courseUsecase{courseRepo: courseRepo, examRepo: examRepo}
}

func (uc *courseUsecase) ListBatches(ctx context.Context, userID uuid.UUID) ([]entity.Batch, error) {
	exam, err := uc.examRepo.FindSelectedExamByUserID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("find selected exam: %w", err)
	}
	if exam == nil {
		// No exam selected yet — nothing to show instead of erroring.
		return []entity.Batch{}, nil
	}

	batches, err := uc.courseRepo.ListBatches(ctx, exam.ID)
	if err != nil {
		return nil, fmt.Errorf("list batches: %w", err)
	}
	return batches, nil
}

func (uc *courseUsecase) GetBatch(ctx context.Context, batchID uuid.UUID) (*entity.Batch, error) {
	batch, err := uc.courseRepo.GetBatchByID(ctx, batchID)
	if err != nil {
		return nil, fmt.Errorf("get batch: %w", err)
	}
	if batch == nil {
		return nil, apperror.ErrBatchNotFound
	}
	return batch, nil
}

func (uc *courseUsecase) ListSubjects(ctx context.Context, batchID uuid.UUID) ([]entity.Subject, error) {
	subjects, err := uc.courseRepo.ListSubjectsByBatch(ctx, batchID)
	if err != nil {
		return nil, fmt.Errorf("list subjects: %w", err)
	}
	return subjects, nil
}

func (uc *courseUsecase) ListChapters(ctx context.Context, subjectID uuid.UUID) ([]entity.Chapter, error) {
	chapters, err := uc.courseRepo.ListChaptersBySubject(ctx, subjectID)
	if err != nil {
		return nil, fmt.Errorf("list chapters: %w", err)
	}
	return chapters, nil
}

func (uc *courseUsecase) ListLectures(ctx context.Context, chapterID uuid.UUID) ([]entity.Lecture, error) {
	lectures, err := uc.courseRepo.ListLecturesByChapter(ctx, chapterID)
	if err != nil {
		return nil, fmt.Errorf("list lectures: %w", err)
	}
	return lectures, nil
}
