package postgres

import (
    "context"
    "errors"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
)

type courseProgressRepository struct {
    db *pgxpool.Pool
}

func NewCourseProgressRepository(db *pgxpool.Pool) *courseProgressRepository {
    return &courseProgressRepository{db: db}
}

// MarkLectureComplete inserts a completion record, resolving chapter/subject/
// batch from the lecture itself. Idempotent: re-marking is a no-op. Returns
// ErrLectureNotFound if the lecture id does not exist.
func (r *courseProgressRepository) MarkLectureComplete(ctx context.Context, userID, lectureID uuid.UUID) error {
    const q = `
        INSERT INTO user_lecture_progress (user_id, lecture_id, chapter_id, subject_id, batch_id)
        SELECT $1, l.id, l.chapter_id, c.subject_id, s.batch_id
        FROM lectures l
        JOIN chapters c ON c.id = l.chapter_id
        JOIN subjects s ON s.id = c.subject_id
        WHERE l.id = $2
        ON CONFLICT (user_id, lecture_id) DO NOTHING
    `
    tag, err := r.db.Exec(ctx, q, userID, lectureID)
    if err != nil {
        return fmt.Errorf("mark lecture complete: %w", err)
    }
    if tag.RowsAffected() == 0 {
        var exists bool
        checkErr := r.db.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM lectures WHERE id = $1)`, lectureID).Scan(&exists)
        if checkErr != nil {
            return fmt.Errorf("check lecture exists: %w", checkErr)
        }
        if !exists {
            return apperror.ErrLectureNotFound
        }
        // Row already existed (already completed) — treat as success.
    }
    return nil
}

func (r *courseProgressRepository) CountLectures(ctx context.Context, userID, batchID uuid.UUID) (int, int, error) {
    const q = `
        SELECT
            COUNT(ulp.id) AS completed,
            COUNT(l.id) AS total
        FROM lectures l
        JOIN chapters c ON c.id = l.chapter_id
        JOIN subjects s ON s.id = c.subject_id
        LEFT JOIN user_lecture_progress ulp ON ulp.lecture_id = l.id AND ulp.user_id = $1
        WHERE s.batch_id = $2
    `
    var completed, total int
    if err := r.db.QueryRow(ctx, q, userID, batchID).Scan(&completed, &total); err != nil {
        return 0, 0, fmt.Errorf("count lectures: %w", err)
    }
    return completed, total, nil
}

func (r *courseProgressRepository) ListChapterCompletion(ctx context.Context, userID, batchID uuid.UUID) ([]entity.ChapterCompletion, error) {
    const q = `
        SELECT c.id, COUNT(l.id) AS total, COUNT(ulp.id) AS completed
        FROM chapters c
        JOIN subjects s ON s.id = c.subject_id
        JOIN lectures l ON l.chapter_id = c.id
        LEFT JOIN user_lecture_progress ulp ON ulp.lecture_id = l.id AND ulp.user_id = $1
        WHERE s.batch_id = $2
        GROUP BY c.id
    `
    rows, err := r.db.Query(ctx, q, userID, batchID)
    if err != nil {
        return nil, fmt.Errorf("list chapter completion: %w", err)
    }
    defer rows.Close()

    var result []entity.ChapterCompletion
    for rows.Next() {
        var cc entity.ChapterCompletion
        if err := rows.Scan(&cc.ChapterID, &cc.TotalLectures, &cc.CompletedLectures); err != nil {
            return nil, fmt.Errorf("scan chapter completion: %w", err)
        }
        result = append(result, cc)
    }
    return result, nil
}

func (r *courseProgressRepository) GetLastWatchedLecture(ctx context.Context, userID, batchID uuid.UUID) (*entity.LectureRef, *time.Time, error) {
    const q = `
        SELECT l.id, l.title, c.id, c.title, ulp.completed_at
        FROM user_lecture_progress ulp
        JOIN lectures l ON l.id = ulp.lecture_id
        JOIN chapters c ON c.id = l.chapter_id
        WHERE ulp.user_id = $1 AND ulp.batch_id = $2
        ORDER BY ulp.completed_at DESC
        LIMIT 1
    `
    var ref entity.LectureRef
    var completedAt time.Time
    err := r.db.QueryRow(ctx, q, userID, batchID).
        Scan(&ref.LectureID, &ref.LectureTitle, &ref.ChapterID, &ref.ChapterTitle, &completedAt)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil, nil
        }
        return nil, nil, fmt.Errorf("get last watched lecture: %w", err)
    }
    return &ref, &completedAt, nil
}

func (r *courseProgressRepository) GetContinueLearningLecture(ctx context.Context, userID, batchID uuid.UUID) (*entity.LectureRef, error) {
    const q = `
        SELECT l.id, l.title, c.id, c.title
        FROM lectures l
        JOIN chapters c ON c.id = l.chapter_id
        JOIN subjects s ON s.id = c.subject_id
        LEFT JOIN user_lecture_progress ulp ON ulp.lecture_id = l.id AND ulp.user_id = $1
        WHERE s.batch_id = $2 AND ulp.id IS NULL
        ORDER BY s.display_order ASC, c.display_order ASC, l.display_order ASC
        LIMIT 1
    `
    var ref entity.LectureRef
    err := r.db.QueryRow(ctx, q, userID, batchID).
        Scan(&ref.LectureID, &ref.LectureTitle, &ref.ChapterID, &ref.ChapterTitle)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, nil
        }
        return nil, fmt.Errorf("get continue learning lecture: %w", err)
    }
    return &ref, nil
}
