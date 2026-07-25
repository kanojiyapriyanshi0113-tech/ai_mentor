package usecase

import (
    "context"
    "fmt"
    "time"

    "github.com/google/uuid"

    "ai-mentor-backend/internal/domain/entity"
    "ai-mentor-backend/internal/domain/repository"
)

type CreateBatchInput struct {
    ExamID      int
    Title       string
    Description string
    Thumbnail   string
}

type UpdateBatchInput struct {
    ID          string
    Title       string
    Description string
    Thumbnail   string
    IsActive    bool
}

type CreateSubjectInput struct {
    BatchID      string
    Name         string
    Icon         string
    DisplayOrder int
}

type UpdateSubjectInput struct {
    ID           string
    Name         string
    Icon         string
    DisplayOrder int
}

type CreateChapterInput struct {
    SubjectID    string
    Title        string
    Description  string
    DisplayOrder int
}

type UpdateChapterInput struct {
    ID           string
    Title        string
    Description  string
    DisplayOrder int
}

type CreateLectureInput struct {
    ChapterID       string
    Title           string
    Description     string
    DurationMinutes int
    VideoURL        string
    IsPreview       bool
    DisplayOrder    int
}

type UpdateLectureInput struct {
    ID              string
    Title           string
    Description     string
    DurationMinutes int
    VideoURL        string
    IsPreview       bool
    DisplayOrder    int
}

type CreatePDFInput struct {
    ChapterID    string
    Title        string
    FileURL      string
    DisplayOrder int
}

type CreateMockTestInput struct {
    BatchID         string
    Title           string
    DurationMinutes int
    TotalQuestions  int
}

type UpdateMockTestInput struct {
    ID              string
    Title           string
    DurationMinutes int
    TotalQuestions  int
}

type CreatePYQInput struct {
    BatchID    string
    ExamName   string
    Year       int
    SubjectTag string
    FileURL    string
}

type UpdatePYQInput struct {
    ID         string
    ExamName   string
    Year       int
    SubjectTag string
    FileURL    string
}

type CreateLiveClassInput struct {
    BatchID     string
    Title       string
    ScheduledAt time.Time
    MeetingURL  string
}

type SendNotificationInput struct {
    BatchID  string
    SenderID string
    Title    string
    Message  string
}

type TeacherUsecase interface {
    GetDashboard(ctx context.Context) (*entity.TeacherDashboardStats, error)

    CreateBatch(ctx context.Context, in CreateBatchInput) (*entity.Batch, error)
    UpdateBatch(ctx context.Context, in UpdateBatchInput) error
    DeleteBatch(ctx context.Context, id string) error
    PublishBatch(ctx context.Context, id string, publish bool) error

    CreateSubject(ctx context.Context, in CreateSubjectInput) (*entity.Subject, error)
    UpdateSubject(ctx context.Context, in UpdateSubjectInput) error
    DeleteSubject(ctx context.Context, id string) error

    CreateChapter(ctx context.Context, in CreateChapterInput) (*entity.Chapter, error)
    UpdateChapter(ctx context.Context, in UpdateChapterInput) error
    DeleteChapter(ctx context.Context, id string) error
    ReorderChapters(ctx context.Context, subjectID string, orderedIDs []string) error

    CreateLecture(ctx context.Context, in CreateLectureInput) (*entity.Lecture, error)
    UpdateLecture(ctx context.Context, in UpdateLectureInput) error
    DeleteLecture(ctx context.Context, id string) error

    UploadPDF(ctx context.Context, in CreatePDFInput) (*entity.PDF, error)
    ReplacePDF(ctx context.Context, id string, fileURL string) error
    DeletePDF(ctx context.Context, id string) error

    CreateMockTest(ctx context.Context, in CreateMockTestInput) (*entity.MockTest, error)
    UpdateMockTest(ctx context.Context, in UpdateMockTestInput) error
    DeleteMockTest(ctx context.Context, id string) error

    UploadPYQ(ctx context.Context, in CreatePYQInput) (*entity.PYQ, error)
    UpdatePYQ(ctx context.Context, in UpdatePYQInput) error
    DeletePYQ(ctx context.Context, id string) error

    CreateLiveClass(ctx context.Context, in CreateLiveClassInput) (*entity.LiveClass, error)

    SendNotification(ctx context.Context, in SendNotificationInput) error
}

type teacherUsecase struct {
    teacherRepo repository.TeacherRepository
}

func NewTeacherUsecase(teacherRepo repository.TeacherRepository) TeacherUsecase {
    return &teacherUsecase{teacherRepo: teacherRepo}
}

func (uc *teacherUsecase) GetDashboard(ctx context.Context) (*entity.TeacherDashboardStats, error) {
    stats, err := uc.teacherRepo.GetDashboardStats(ctx)
    if err != nil {
        return nil, fmt.Errorf("get dashboard stats: %w", err)
    }
    return stats, nil
}

func (uc *teacherUsecase) CreateBatch(ctx context.Context, in CreateBatchInput) (*entity.Batch, error) {
    b := &entity.Batch{
        ExamID:      in.ExamID,
        Title:       in.Title,
        Description: in.Description,
        Thumbnail:   in.Thumbnail,
        IsActive:    true,
        CreatedAt:   time.Now(),
    }
    if err := uc.teacherRepo.CreateBatch(ctx, b); err != nil {
        return nil, fmt.Errorf("create batch: %w", err)
    }
    return b, nil
}

func (uc *teacherUsecase) UpdateBatch(ctx context.Context, in UpdateBatchInput) error {
    b := &entity.Batch{
        ID:          in.ID,
        Title:       in.Title,
        Description: in.Description,
        Thumbnail:   in.Thumbnail,
        IsActive:    in.IsActive,
    }
    if err := uc.teacherRepo.UpdateBatch(ctx, b); err != nil {
        return fmt.Errorf("update batch: %w", err)
    }
    return nil
}

func (uc *teacherUsecase) DeleteBatch(ctx context.Context, id string) error {
    batchID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid batch id: %w", err)
    }
    return uc.teacherRepo.DeleteBatch(ctx, batchID)
}

func (uc *teacherUsecase) PublishBatch(ctx context.Context, id string, publish bool) error {
    batchID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid batch id: %w", err)
    }
    return uc.teacherRepo.PublishBatch(ctx, batchID, publish)
}

func (uc *teacherUsecase) CreateSubject(ctx context.Context, in CreateSubjectInput) (*entity.Subject, error) {
    s := &entity.Subject{
        BatchID:      in.BatchID,
        Name:         in.Name,
        Icon:         in.Icon,
        DisplayOrder: in.DisplayOrder,
    }
    if err := uc.teacherRepo.CreateSubject(ctx, s); err != nil {
        return nil, fmt.Errorf("create subject: %w", err)
    }
    return s, nil
}

func (uc *teacherUsecase) UpdateSubject(ctx context.Context, in UpdateSubjectInput) error {
    s := &entity.Subject{
        ID:           in.ID,
        Name:         in.Name,
        Icon:         in.Icon,
        DisplayOrder: in.DisplayOrder,
    }
    return uc.teacherRepo.UpdateSubject(ctx, s)
}

func (uc *teacherUsecase) DeleteSubject(ctx context.Context, id string) error {
    subjectID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid subject id: %w", err)
    }
    return uc.teacherRepo.DeleteSubject(ctx, subjectID)
}

func (uc *teacherUsecase) CreateChapter(ctx context.Context, in CreateChapterInput) (*entity.Chapter, error) {
    c := &entity.Chapter{
        SubjectID:    in.SubjectID,
        Title:        in.Title,
        Description:  in.Description,
        DisplayOrder: in.DisplayOrder,
    }
    if err := uc.teacherRepo.CreateChapter(ctx, c); err != nil {
        return nil, fmt.Errorf("create chapter: %w", err)
    }
    return c, nil
}

func (uc *teacherUsecase) UpdateChapter(ctx context.Context, in UpdateChapterInput) error {
    c := &entity.Chapter{
        ID:           in.ID,
        Title:        in.Title,
        Description:  in.Description,
        DisplayOrder: in.DisplayOrder,
    }
    return uc.teacherRepo.UpdateChapter(ctx, c)
}

func (uc *teacherUsecase) DeleteChapter(ctx context.Context, id string) error {
    chapterID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid chapter id: %w", err)
    }
    return uc.teacherRepo.DeleteChapter(ctx, chapterID)
}

func (uc *teacherUsecase) ReorderChapters(ctx context.Context, subjectID string, orderedIDs []string) error {
    sID, err := uuid.Parse(subjectID)
    if err != nil {
        return fmt.Errorf("invalid subject id: %w", err)
    }
    ids := make([]uuid.UUID, 0, len(orderedIDs))
    for _, idStr := range orderedIDs {
        id, err := uuid.Parse(idStr)
        if err != nil {
            return fmt.Errorf("invalid chapter id %q: %w", idStr, err)
        }
        ids = append(ids, id)
    }
    return uc.teacherRepo.ReorderChapters(ctx, sID, ids)
}

func (uc *teacherUsecase) CreateLecture(ctx context.Context, in CreateLectureInput) (*entity.Lecture, error) {
    l := &entity.Lecture{
        ChapterID:       in.ChapterID,
        Title:           in.Title,
        Description:     in.Description,
        DurationMinutes: in.DurationMinutes,
        VideoURL:        in.VideoURL,
        IsPreview:       in.IsPreview,
        DisplayOrder:    in.DisplayOrder,
    }
    if err := uc.teacherRepo.CreateLecture(ctx, l); err != nil {
        return nil, fmt.Errorf("create lecture: %w", err)
    }
    return l, nil
}

func (uc *teacherUsecase) UpdateLecture(ctx context.Context, in UpdateLectureInput) error {
    l := &entity.Lecture{
        ID:              in.ID,
        Title:           in.Title,
        Description:     in.Description,
        DurationMinutes: in.DurationMinutes,
        VideoURL:        in.VideoURL,
        IsPreview:       in.IsPreview,
        DisplayOrder:    in.DisplayOrder,
    }
    return uc.teacherRepo.UpdateLecture(ctx, l)
}

func (uc *teacherUsecase) DeleteLecture(ctx context.Context, id string) error {
    lectureID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid lecture id: %w", err)
    }
    return uc.teacherRepo.DeleteLecture(ctx, lectureID)
}

func (uc *teacherUsecase) UploadPDF(ctx context.Context, in CreatePDFInput) (*entity.PDF, error) {
    p := &entity.PDF{
        ChapterID:    in.ChapterID,
        Title:        in.Title,
        FileURL:      in.FileURL,
        DisplayOrder: in.DisplayOrder,
    }
    if err := uc.teacherRepo.CreatePDF(ctx, p); err != nil {
        return nil, fmt.Errorf("upload pdf: %w", err)
    }
    return p, nil
}

func (uc *teacherUsecase) ReplacePDF(ctx context.Context, id string, fileURL string) error {
    pdfID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid pdf id: %w", err)
    }
    return uc.teacherRepo.ReplacePDF(ctx, pdfID, fileURL)
}

func (uc *teacherUsecase) DeletePDF(ctx context.Context, id string) error {
    pdfID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid pdf id: %w", err)
    }
    return uc.teacherRepo.DeletePDF(ctx, pdfID)
}

func (uc *teacherUsecase) CreateMockTest(ctx context.Context, in CreateMockTestInput) (*entity.MockTest, error) {
    m := &entity.MockTest{
        BatchID:         in.BatchID,
        Title:           in.Title,
        DurationMinutes: in.DurationMinutes,
        TotalQuestions:  in.TotalQuestions,
    }
    if err := uc.teacherRepo.CreateMockTest(ctx, m); err != nil {
        return nil, fmt.Errorf("create mock test: %w", err)
    }
    return m, nil
}

func (uc *teacherUsecase) UpdateMockTest(ctx context.Context, in UpdateMockTestInput) error {
    m := &entity.MockTest{
        ID:              in.ID,
        Title:           in.Title,
        DurationMinutes: in.DurationMinutes,
        TotalQuestions:  in.TotalQuestions,
    }
    return uc.teacherRepo.UpdateMockTest(ctx, m)
}

func (uc *teacherUsecase) DeleteMockTest(ctx context.Context, id string) error {
    mockTestID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid mock test id: %w", err)
    }
    return uc.teacherRepo.DeleteMockTest(ctx, mockTestID)
}

func (uc *teacherUsecase) UploadPYQ(ctx context.Context, in CreatePYQInput) (*entity.PYQ, error) {
    p := &entity.PYQ{
        BatchID:    in.BatchID,
        ExamName:   in.ExamName,
        Year:       in.Year,
        SubjectTag: in.SubjectTag,
        FileURL:    in.FileURL,
    }
    if err := uc.teacherRepo.CreatePYQ(ctx, p); err != nil {
        return nil, fmt.Errorf("upload pyq: %w", err)
    }
    return p, nil
}

func (uc *teacherUsecase) UpdatePYQ(ctx context.Context, in UpdatePYQInput) error {
    p := &entity.PYQ{
        ID:         in.ID,
        ExamName:   in.ExamName,
        Year:       in.Year,
        SubjectTag: in.SubjectTag,
        FileURL:    in.FileURL,
    }
    return uc.teacherRepo.UpdatePYQ(ctx, p)
}

func (uc *teacherUsecase) DeletePYQ(ctx context.Context, id string) error {
    pyqID, err := uuid.Parse(id)
    if err != nil {
        return fmt.Errorf("invalid pyq id: %w", err)
    }
    return uc.teacherRepo.DeletePYQ(ctx, pyqID)
}

func (uc *teacherUsecase) CreateLiveClass(ctx context.Context, in CreateLiveClassInput) (*entity.LiveClass, error) {
    l := &entity.LiveClass{
        BatchID:     in.BatchID,
        Title:       in.Title,
        ScheduledAt: in.ScheduledAt,
        MeetingURL:  in.MeetingURL,
    }
    if err := uc.teacherRepo.CreateLiveClass(ctx, l); err != nil {
        return nil, fmt.Errorf("create live class: %w", err)
    }
    return l, nil
}

func (uc *teacherUsecase) SendNotification(ctx context.Context, in SendNotificationInput) error {
    senderID, err := uuid.Parse(in.SenderID)
    if err != nil {
        return fmt.Errorf("invalid sender id: %w", err)
    }
    n := &entity.Notification{
        BatchID:  in.BatchID,
        SenderID: senderID.String(),
        Title:    in.Title,
        Message:  in.Message,
    }
    if err := uc.teacherRepo.SendNotificationToBatch(ctx, n); err != nil {
        return fmt.Errorf("send notification: %w", err)
    }
    return nil
}
