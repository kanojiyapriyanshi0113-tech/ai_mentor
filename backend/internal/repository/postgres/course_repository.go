package postgres

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"ai-mentor-backend/internal/domain/entity"
)

type courseRepository struct {
	db *pgxpool.Pool
}

func NewCourseRepository(db *pgxpool.Pool) *courseRepository {
	return &courseRepository{db: db}
}

func (r *courseRepository) ListBatches(ctx context.Context, examID int) ([]entity.Batch, error) {
	const q = `
		SELECT id, exam_id, title, description, thumbnail, is_active, created_at
		FROM batches
		WHERE is_active = true AND exam_id = $1
		ORDER BY display_order ASC, created_at DESC
	`
	rows, err := r.db.Query(ctx, q, examID)
	if err != nil {
		return nil, fmt.Errorf("list batches: %w", err)
	}
	defer rows.Close()

	var batches []entity.Batch
	for rows.Next() {
		var b entity.Batch
		if err := rows.Scan(&b.ID, &b.ExamID, &b.Title, &b.Description, &b.Thumbnail, &b.IsActive, &b.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan batch: %w", err)
		}
		batches = append(batches, b)
	}
	return batches, nil
}

func (r *courseRepository) GetBatchByID(ctx context.Context, batchID uuid.UUID) (*entity.Batch, error) {
	const q = `
		SELECT id, exam_id, title, description, thumbnail, is_active, created_at
		FROM batches
		WHERE id = $1
	`
	var b entity.Batch
	err := r.db.QueryRow(ctx, q, batchID).
		Scan(&b.ID, &b.ExamID, &b.Title, &b.Description, &b.Thumbnail, &b.IsActive, &b.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, fmt.Errorf("get batch: %w", err)
	}
	return &b, nil
}

func (r *courseRepository) ListSubjectsByBatch(ctx context.Context, batchID uuid.UUID) ([]entity.Subject, error) {
	const q = `
		SELECT id, batch_id, name, icon, display_order
		FROM subjects
		WHERE batch_id = $1
		ORDER BY display_order ASC
	`
	rows, err := r.db.Query(ctx, q, batchID)
	if err != nil {
		return nil, fmt.Errorf("list subjects: %w", err)
	}
	defer rows.Close()

	var subjects []entity.Subject
	for rows.Next() {
		var s entity.Subject
		if err := rows.Scan(&s.ID, &s.BatchID, &s.Name, &s.Icon, &s.DisplayOrder); err != nil {
			return nil, fmt.Errorf("scan subject: %w", err)
		}
		subjects = append(subjects, s)
	}
	return subjects, nil
}

func (r *courseRepository) ListChaptersBySubject(ctx context.Context, subjectID uuid.UUID) ([]entity.Chapter, error) {
	const q = `
		SELECT id, subject_id, title, description, display_order
		FROM chapters
		WHERE subject_id = $1
		ORDER BY display_order ASC
	`
	rows, err := r.db.Query(ctx, q, subjectID)
	if err != nil {
		return nil, fmt.Errorf("list chapters: %w", err)
	}
	defer rows.Close()

	var chapters []entity.Chapter
	for rows.Next() {
		var c entity.Chapter
		if err := rows.Scan(&c.ID, &c.SubjectID, &c.Title, &c.Description, &c.DisplayOrder); err != nil {
			return nil, fmt.Errorf("scan chapter: %w", err)
		}
		chapters = append(chapters, c)
	}
	return chapters, nil
}

func (r *courseRepository) ListLecturesByChapter(ctx context.Context, chapterID uuid.UUID) ([]entity.Lecture, error) {
	const q = `
		SELECT id, chapter_id, title, description, duration_minutes, video_url, is_preview, display_order
		FROM lectures
		WHERE chapter_id = $1
		ORDER BY display_order ASC
	`
	rows, err := r.db.Query(ctx, q, chapterID)
	if err != nil {
		return nil, fmt.Errorf("list lectures: %w", err)
	}
	defer rows.Close()
	var lectures []entity.Lecture
	for rows.Next() {
		var l entity.Lecture
		if err := rows.Scan(&l.ID, &l.ChapterID, &l.Title, &l.Description, &l.DurationMinutes, &l.VideoURL, &l.IsPreview, &l.DisplayOrder); err != nil {
			return nil, fmt.Errorf("scan lecture: %w", err)
		}
		lectures = append(lectures, l)
	}
	return lectures, nil
}
