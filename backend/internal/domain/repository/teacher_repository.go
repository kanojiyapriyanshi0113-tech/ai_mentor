package repository

import (
    "context"
    "time"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
)

// TeacherRepository provides content-management persistence for the
// teacher/admin role. It does not touch subscriptions, payments, users,
// or settings.
type TeacherRepository interface {
    // Batch
    CreateBatch(ctx context.Context, b *entity.Batch) error
    UpdateBatch(ctx context.Context, b *entity.Batch) error
    DeleteBatch(ctx context.Context, id uuid.UUID) error
    PublishBatch(ctx context.Context, id uuid.UUID, publish bool) error

    // Subject
    CreateSubject(ctx context.Context, s *entity.Subject) error
    UpdateSubject(ctx context.Context, s *entity.Subject) error
    DeleteSubject(ctx context.Context, id uuid.UUID) error

    // Chapter
    CreateChapter(ctx context.Context, c *entity.Chapter) error
    UpdateChapter(ctx context.Context, c *entity.Chapter) error
    DeleteChapter(ctx context.Context, id uuid.UUID) error
    ReorderChapters(ctx context.Context, subjectID uuid.UUID, orderedIDs []uuid.UUID) error

    // Lecture
    CreateLecture(ctx context.Context, l *entity.Lecture) error
    UpdateLecture(ctx context.Context, l *entity.Lecture) error
    DeleteLecture(ctx context.Context, id uuid.UUID) error

    // PDF
    CreatePDF(ctx context.Context, p *entity.PDF) error
    ReplacePDF(ctx context.Context, id uuid.UUID, fileURL string) error
    DeletePDF(ctx context.Context, id uuid.UUID) error

    // Mock Test
    CreateMockTest(ctx context.Context, m *entity.MockTest) error
    UpdateMockTest(ctx context.Context, m *entity.MockTest) error
    DeleteMockTest(ctx context.Context, id uuid.UUID) error

    // PYQ
    CreatePYQ(ctx context.Context, p *entity.PYQ) error
    UpdatePYQ(ctx context.Context, p *entity.PYQ) error
    DeletePYQ(ctx context.Context, id uuid.UUID) error

    // Live Class
    CreateLiveClass(ctx context.Context, l *entity.LiveClass) error
    ListUpcomingLiveClasses(ctx context.Context, since time.Time, limit int) ([]entity.LiveClass, error)

    // Notification
    SendNotificationToBatch(ctx context.Context, n *entity.Notification) error

    // Dashboard
    GetDashboardStats(ctx context.Context) (*entity.TeacherDashboardStats, error)
}
