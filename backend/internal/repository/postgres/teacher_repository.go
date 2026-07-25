package postgres

import (
    "context"
    "fmt"
    "strings"
    "time"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/domain/repository"
)

type teacherRepository struct {
    db *pgxpool.Pool
}

func NewTeacherRepository(db *pgxpool.Pool) *teacherRepository {
    return &teacherRepository{db: db}
}

// ---------- Batch ----------

func (r *teacherRepository) CreateBatch(ctx context.Context, b *entity.Batch) error {
    if b.ID == "" {
        b.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO batches (id, exam_id, title, description, thumbnail, is_active, created_at)
        VALUES ($1, $2, $3, $4, $5, $6, now())
    `
    _, err := r.db.Exec(ctx, q, b.ID, b.ExamID, b.Title, b.Description, b.Thumbnail, b.IsActive)
    if err != nil {
        return fmt.Errorf("create batch: %w", err)
    }
    return nil
}

func (r *teacherRepository) UpdateBatch(ctx context.Context, b *entity.Batch) error {
    const q = `
        UPDATE batches
        SET title = $1, description = $2, thumbnail = $3, is_active = $4
        WHERE id = $5
    `
    tag, err := r.db.Exec(ctx, q, b.Title, b.Description, b.Thumbnail, b.IsActive, b.ID)
    if err != nil {
        return fmt.Errorf("update batch: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrBatchNotFound
    }
    return nil
}

func (r *teacherRepository) DeleteBatch(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE batches SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete batch: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrBatchNotFound
    }
    return nil
}

func (r *teacherRepository) PublishBatch(ctx context.Context, id uuid.UUID, publish bool) error {
    const q = `UPDATE batches SET is_published = $1 WHERE id = $2`
    tag, err := r.db.Exec(ctx, q, publish, id.String())
    if err != nil {
        return fmt.Errorf("publish batch: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrBatchNotFound
    }
    return nil
}

// ---------- Subject ----------

func (r *teacherRepository) CreateSubject(ctx context.Context, s *entity.Subject) error {
    if s.ID == "" {
        s.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO subjects (id, batch_id, name, icon, display_order, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, s.ID, s.BatchID, s.Name, s.Icon, s.DisplayOrder)
    if err != nil {
        return fmt.Errorf("create subject: %w", err)
    }
    return nil
}

func (r *teacherRepository) UpdateSubject(ctx context.Context, s *entity.Subject) error {
    const q = `UPDATE subjects SET name = $1, icon = $2, display_order = $3, updated_at = now() WHERE id = $4`
    tag, err := r.db.Exec(ctx, q, s.Name, s.Icon, s.DisplayOrder, s.ID)
    if err != nil {
        return fmt.Errorf("update subject: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrSubjectNotFound
    }
    return nil
}

func (r *teacherRepository) DeleteSubject(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE subjects SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete subject: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrSubjectNotFound
    }
    return nil
}

// ---------- Chapter ----------

func (r *teacherRepository) CreateChapter(ctx context.Context, c *entity.Chapter) error {
    if c.ID == "" {
        c.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO chapters (id, subject_id, title, description, display_order, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, c.ID, c.SubjectID, c.Title, c.Description, c.DisplayOrder)
    if err != nil {
        return fmt.Errorf("create chapter: %w", err)
    }
    return nil
}

func (r *teacherRepository) UpdateChapter(ctx context.Context, c *entity.Chapter) error {
    const q = `UPDATE chapters SET title = $1, description = $2, display_order = $3, updated_at = now() WHERE id = $4`
    tag, err := r.db.Exec(ctx, q, c.Title, c.Description, c.DisplayOrder, c.ID)
    if err != nil {
        return fmt.Errorf("update chapter: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrChapterNotFound
    }
    return nil
}

func (r *teacherRepository) DeleteChapter(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE chapters SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete chapter: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrChapterNotFound
    }
    return nil
}

func (r *teacherRepository) ReorderChapters(ctx context.Context, subjectID uuid.UUID, orderedIDs []uuid.UUID) error {
    tx, err := r.db.Begin(ctx)
    if err != nil {
        return fmt.Errorf("begin tx: %w", err)
    }
    defer tx.Rollback(ctx)

    for i, id := range orderedIDs {
        _, err := tx.Exec(ctx,
            `UPDATE chapters SET display_order = $1, updated_at = now() WHERE id = $2 AND subject_id = $3`,
            i, id.String(), subjectID.String())
        if err != nil {
            return fmt.Errorf("reorder chapter %s: %w", id, err)
        }
    }

    if err := tx.Commit(ctx); err != nil {
        return fmt.Errorf("commit reorder: %w", err)
    }
    return nil
}

// ---------- Lecture ----------

func (r *teacherRepository) CreateLecture(ctx context.Context, l *entity.Lecture) error {
    if l.ID == "" {
        l.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO lectures (id, chapter_id, title, description, duration_minutes, video_url, is_preview, display_order, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, l.ID, l.ChapterID, l.Title, l.Description, l.DurationMinutes, l.VideoURL, l.IsPreview, l.DisplayOrder)
    if err != nil {
        return fmt.Errorf("create lecture: %w", err)
    }
    return nil
}

func (r *teacherRepository) UpdateLecture(ctx context.Context, l *entity.Lecture) error {
    const q = `
        UPDATE lectures
        SET title = $1, description = $2, duration_minutes = $3, video_url = $4, is_preview = $5, display_order = $6, updated_at = now()
        WHERE id = $7
    `
    tag, err := r.db.Exec(ctx, q, l.Title, l.Description, l.DurationMinutes, l.VideoURL, l.IsPreview, l.DisplayOrder, l.ID)
    if err != nil {
        return fmt.Errorf("update lecture: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrLectureNotFound
    }
    return nil
}

func (r *teacherRepository) DeleteLecture(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE lectures SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete lecture: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrLectureNotFound
    }
    return nil
}

// ---------- PDF ----------

func (r *teacherRepository) CreatePDF(ctx context.Context, p *entity.PDF) error {
    if p.ID == "" {
        p.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO pdfs (id, chapter_id, title, file_url, display_order, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, p.ID, p.ChapterID, p.Title, p.FileURL, p.DisplayOrder)
    if err != nil {
        return fmt.Errorf("create pdf: %w", err)
    }
    return nil
}

func (r *teacherRepository) ReplacePDF(ctx context.Context, id uuid.UUID, fileURL string) error {
    const q = `UPDATE pdfs SET file_url = $1, updated_at = now() WHERE id = $2`
    tag, err := r.db.Exec(ctx, q, fileURL, id.String())
    if err != nil {
        return fmt.Errorf("replace pdf: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrPDFNotFound
    }
    return nil
}

func (r *teacherRepository) DeletePDF(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE pdfs SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete pdf: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrPDFNotFound
    }
    return nil
}

// ---------- Mock Test ----------

func (r *teacherRepository) CreateMockTest(ctx context.Context, m *entity.MockTest) error {
    if m.ID == "" {
        m.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO mock_tests (id, batch_id, title, duration_minutes, total_questions, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, m.ID, m.BatchID, m.Title, m.DurationMinutes, m.TotalQuestions)
    if err != nil {
        return fmt.Errorf("create mock test: %w", err)
    }
    return nil
}

func (r *teacherRepository) UpdateMockTest(ctx context.Context, m *entity.MockTest) error {
    const q = `UPDATE mock_tests SET title = $1, duration_minutes = $2, total_questions = $3, updated_at = now() WHERE id = $4`
    tag, err := r.db.Exec(ctx, q, m.Title, m.DurationMinutes, m.TotalQuestions, m.ID)
    if err != nil {
        return fmt.Errorf("update mock test: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrMockTestNotFound
    }
    return nil
}

func (r *teacherRepository) DeleteMockTest(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE mock_tests SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete mock test: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrMockTestNotFound
    }
    return nil
}

// ---------- PYQ ----------

func (r *teacherRepository) CreatePYQ(ctx context.Context, p *entity.PYQ) error {
    if p.ID == "" {
        p.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO pyqs (id, batch_id, exam_name, year, subject_tag, file_url, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, p.ID, p.BatchID, p.ExamName, p.Year, p.SubjectTag, p.FileURL)
    if err != nil {
        return fmt.Errorf("create pyq: %w", err)
    }
    return nil
}

func (r *teacherRepository) UpdatePYQ(ctx context.Context, p *entity.PYQ) error {
    const q = `UPDATE pyqs SET exam_name = $1, year = $2, subject_tag = $3, file_url = $4, updated_at = now() WHERE id = $5`
    tag, err := r.db.Exec(ctx, q, p.ExamName, p.Year, p.SubjectTag, p.FileURL, p.ID)
    if err != nil {
        return fmt.Errorf("update pyq: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrPYQNotFound
    }
    return nil
}

func (r *teacherRepository) DeletePYQ(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE pyqs SET is_active = false WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete pyq: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrPYQNotFound
    }
    return nil
}

// ---------- Live Class ----------

func (r *teacherRepository) CreateLiveClass(ctx context.Context, l *entity.LiveClass) error {
    if l.ID == "" {
        l.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO live_classes (id, batch_id, title, scheduled_at, meeting_url, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, l.ID, l.BatchID, l.Title, l.ScheduledAt, l.MeetingURL)
    if err != nil {
        return fmt.Errorf("create live class: %w", err)
    }
    return nil
}

func (r *teacherRepository) ListUpcomingLiveClasses(ctx context.Context, since time.Time, limit int) ([]entity.LiveClass, error) {
    const q = `
        SELECT id, batch_id, title, scheduled_at, meeting_url, is_active, created_at, updated_at
        FROM live_classes
        WHERE is_active = true AND scheduled_at >= $1
        ORDER BY scheduled_at ASC
        LIMIT $2
    `
    rows, err := r.db.Query(ctx, q, since, limit)
    if err != nil {
        return nil, fmt.Errorf("list upcoming live classes: %w", err)
    }
    defer rows.Close()

    var classes []entity.LiveClass
    for rows.Next() {
        var l entity.LiveClass
        if err := rows.Scan(&l.ID, &l.BatchID, &l.Title, &l.ScheduledAt, &l.MeetingURL, &l.IsActive, &l.CreatedAt, &l.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan live class: %w", err)
        }
        classes = append(classes, l)
    }
    return classes, nil
}

// ---------- Notification ----------

func (r *teacherRepository) SendNotificationToBatch(ctx context.Context, n *entity.Notification) error {
    if n.ID == "" {
        n.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO notifications (id, batch_id, sender_id, title, message, created_at)
        VALUES ($1, $2, $3, $4, $5, now())
    `
    _, err := r.db.Exec(ctx, q, n.ID, n.BatchID, n.SenderID, n.Title, n.Message)
    if err != nil {
        return fmt.Errorf("send notification: %w", err)
    }
    return nil
}

// ---------- Dashboard ----------

func (r *teacherRepository) GetDashboardStats(ctx context.Context) (*entity.TeacherDashboardStats, error) {
    var stats entity.TeacherDashboardStats
    const q = `
        SELECT
            (SELECT COUNT(*) FROM users WHERE role = 'student') AS total_students,
            (SELECT COUNT(*) FROM batches WHERE is_active = true) AS total_batches,
            (SELECT COUNT(*) FROM subjects WHERE is_active = true) AS total_subjects,
            (SELECT COUNT(*) FROM chapters WHERE is_active = true) AS total_chapters,
            (SELECT COUNT(*) FROM lectures WHERE is_active = true) AS total_lectures,
            (SELECT COUNT(*) FROM pdfs WHERE is_active = true) AS total_pdfs,
            (SELECT COUNT(*) FROM mock_tests WHERE is_active = true) AS total_mock_tests
    `
    err := r.db.QueryRow(ctx, q).Scan(
        &stats.TotalStudents, &stats.TotalBatches, &stats.TotalSubjects,
        &stats.TotalChapters, &stats.TotalLectures, &stats.TotalPDFs, &stats.TotalMockTests,
    )
    if err != nil {
        return nil, fmt.Errorf("get dashboard stats: %w", err)
    }

    upcoming, err := r.ListUpcomingLiveClasses(ctx, time.Now(), 10)
    if err != nil {
        return nil, fmt.Errorf("list upcoming live classes: %w", err)
    }
    stats.UpcomingLiveClasses = upcoming

    return &stats, nil
}
// ---------- PDF / Mock Test / PYQ Listing ----------

func (r *teacherRepository) ListPDFs(ctx context.Context, filter repository.PDFFilter) ([]entity.PDF, error) {
    q := `SELECT p.id, p.chapter_id, p.title, p.file_url, p.display_order, p.is_active, p.created_at, p.updated_at FROM pdfs p`
    conditions := []string{"p.is_active = true"}
    args := []interface{}{}
    argPos := 1

    if filter.SubjectID != "" || filter.BatchID != "" {
        q += " JOIN chapters c ON c.id = p.chapter_id"
    }
    if filter.BatchID != "" {
        q += " JOIN subjects s ON s.id = c.subject_id"
    }
    if filter.ChapterID != "" {
        conditions = append(conditions, fmt.Sprintf("p.chapter_id = $%d", argPos))
        args = append(args, filter.ChapterID)
        argPos++
    }
    if filter.SubjectID != "" {
        conditions = append(conditions, fmt.Sprintf("c.subject_id = $%d", argPos))
        args = append(args, filter.SubjectID)
        argPos++
    }
    if filter.BatchID != "" {
        conditions = append(conditions, fmt.Sprintf("s.batch_id = $%d", argPos))
        args = append(args, filter.BatchID)
        argPos++
    }

    q += " WHERE " + strings.Join(conditions, " AND ") + " ORDER BY p.display_order ASC"

    rows, err := r.db.Query(ctx, q, args...)
    if err != nil {
        return nil, fmt.Errorf("list pdfs: %w", err)
    }
    defer rows.Close()

    var pdfs []entity.PDF
    for rows.Next() {
        var p entity.PDF
        if err := rows.Scan(&p.ID, &p.ChapterID, &p.Title, &p.FileURL, &p.DisplayOrder, &p.IsActive, &p.CreatedAt, &p.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan pdf: %w", err)
        }
        pdfs = append(pdfs, p)
    }
    return pdfs, nil
}

func (r *teacherRepository) ListMockTests(ctx context.Context, filter repository.MockTestFilter) ([]entity.MockTest, error) {
    q := `SELECT id, batch_id, title, duration_minutes, total_questions, is_active, created_at, updated_at FROM mock_tests WHERE is_active = true`
    args := []interface{}{}
    if filter.BatchID != "" {
        q += " AND batch_id = $1"
        args = append(args, filter.BatchID)
    }
    q += " ORDER BY created_at DESC"

    rows, err := r.db.Query(ctx, q, args...)
    if err != nil {
        return nil, fmt.Errorf("list mock tests: %w", err)
    }
    defer rows.Close()

    var tests []entity.MockTest
    for rows.Next() {
        var m entity.MockTest
        if err := rows.Scan(&m.ID, &m.BatchID, &m.Title, &m.DurationMinutes, &m.TotalQuestions, &m.IsActive, &m.CreatedAt, &m.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan mock test: %w", err)
        }
        tests = append(tests, m)
    }
    return tests, nil
}

func (r *teacherRepository) ListPYQs(ctx context.Context, filter repository.PYQFilter) ([]entity.PYQ, error) {
    q := `SELECT id, batch_id, exam_name, year, subject_tag, file_url, is_active, created_at, updated_at FROM pyqs WHERE is_active = true`
    args := []interface{}{}
    if filter.BatchID != "" {
        q += " AND batch_id = $1"
        args = append(args, filter.BatchID)
    }
    q += " ORDER BY year DESC"

    rows, err := r.db.Query(ctx, q, args...)
    if err != nil {
        return nil, fmt.Errorf("list pyqs: %w", err)
    }
    defer rows.Close()

    var pyqs []entity.PYQ
    for rows.Next() {
        var p entity.PYQ
        if err := rows.Scan(&p.ID, &p.BatchID, &p.ExamName, &p.Year, &p.SubjectTag, &p.FileURL, &p.IsActive, &p.CreatedAt, &p.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan pyq: %w", err)
        }
        pyqs = append(pyqs, p)
    }
    return pyqs, nil
}
