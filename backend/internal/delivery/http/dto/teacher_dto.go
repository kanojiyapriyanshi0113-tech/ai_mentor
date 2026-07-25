package dto

import "time"

type CreateBatchRequest struct {
    ExamID      int    `json:"exam_id" binding:"required"`
    Title       string `json:"title" binding:"required"`
    Description string `json:"description"`
    Thumbnail   string `json:"thumbnail"`
}

type UpdateBatchRequest struct {
    Title       string `json:"title" binding:"required"`
    Description string `json:"description"`
    Thumbnail   string `json:"thumbnail"`
    IsActive    bool   `json:"is_active"`
}

type PublishBatchRequest struct {
    Publish bool `json:"publish"`
}

type CreateSubjectRequest struct {
    BatchID      string `json:"batch_id" binding:"required"`
    Name         string `json:"name" binding:"required"`
    Icon         string `json:"icon"`
    DisplayOrder int    `json:"display_order"`
}

type UpdateSubjectRequest struct {
    Name         string `json:"name" binding:"required"`
    Icon         string `json:"icon"`
    DisplayOrder int    `json:"display_order"`
}

type CreateChapterRequest struct {
    SubjectID    string `json:"subject_id" binding:"required"`
    Title        string `json:"title" binding:"required"`
    Description  string `json:"description"`
    DisplayOrder int    `json:"display_order"`
}

type UpdateChapterRequest struct {
    Title        string `json:"title" binding:"required"`
    Description  string `json:"description"`
    DisplayOrder int    `json:"display_order"`
}

type ReorderChaptersRequest struct {
    OrderedIDs []string `json:"ordered_ids" binding:"required"`
}

type CreateLectureRequest struct {
    ChapterID       string `json:"chapter_id" binding:"required"`
    Title           string `json:"title" binding:"required"`
    Description     string `json:"description"`
    DurationMinutes int    `json:"duration_minutes"`
    VideoURL        string `json:"video_url" binding:"required"`
    IsPreview       bool   `json:"is_preview"`
    DisplayOrder    int    `json:"display_order"`
}

type UpdateLectureRequest struct {
    Title           string `json:"title" binding:"required"`
    Description     string `json:"description"`
    DurationMinutes int    `json:"duration_minutes"`
    VideoURL        string `json:"video_url" binding:"required"`
    IsPreview       bool   `json:"is_preview"`
    DisplayOrder    int    `json:"display_order"`
}

type UploadPDFRequest struct {
    ChapterID    string `json:"chapter_id" binding:"required"`
    Title        string `json:"title" binding:"required"`
    FileURL      string `json:"file_url" binding:"required"`
    DisplayOrder int    `json:"display_order"`
}

type ReplacePDFRequest struct {
    FileURL string `json:"file_url" binding:"required"`
}

type CreateMockTestRequest struct {
    BatchID         string `json:"batch_id" binding:"required"`
    Title           string `json:"title" binding:"required"`
    DurationMinutes int    `json:"duration_minutes"`
    TotalQuestions  int    `json:"total_questions"`
}

type UpdateMockTestRequest struct {
    Title           string `json:"title" binding:"required"`
    DurationMinutes int    `json:"duration_minutes"`
    TotalQuestions  int    `json:"total_questions"`
}

type UploadPYQRequest struct {
    BatchID    string `json:"batch_id" binding:"required"`
    ExamName   string `json:"exam_name" binding:"required"`
    Year       int    `json:"year" binding:"required"`
    SubjectTag string `json:"subject_tag"`
    FileURL    string `json:"file_url" binding:"required"`
}

type UpdatePYQRequest struct {
    ExamName   string `json:"exam_name" binding:"required"`
    Year       int    `json:"year" binding:"required"`
    SubjectTag string `json:"subject_tag"`
    FileURL    string `json:"file_url" binding:"required"`
}

type CreateLiveClassRequest struct {
    BatchID     string    `json:"batch_id" binding:"required"`
    Title       string    `json:"title" binding:"required"`
    ScheduledAt time.Time `json:"scheduled_at" binding:"required"`
    MeetingURL  string    `json:"meeting_url"`
}

type SendNotificationRequest struct {
    BatchID string `json:"batch_id" binding:"required"`
    Title   string `json:"title" binding:"required"`
    Message string `json:"message" binding:"required"`
}

type TeacherDashboardResponse struct {
    TotalStudents       int                 `json:"total_students"`
    TotalBatches        int                 `json:"total_batches"`
    TotalSubjects       int                 `json:"total_subjects"`
    TotalChapters       int                 `json:"total_chapters"`
    TotalLectures       int                 `json:"total_lectures"`
    TotalPDFs           int                 `json:"total_pdfs"`
    TotalMockTests      int                 `json:"total_mock_tests"`
    UpcomingLiveClasses []LiveClassResponse `json:"upcoming_live_classes"`
}

type LiveClassResponse struct {
    ID          string    `json:"id"`
    BatchID     string    `json:"batch_id"`
    Title       string    `json:"title"`
    ScheduledAt time.Time `json:"scheduled_at"`
    MeetingURL  string    `json:"meeting_url"`
}

type PDFResponse struct {
    ID           string `json:"id"`
    ChapterID    string `json:"chapter_id"`
    Title        string `json:"title"`
    FileURL      string `json:"file_url"`
    DisplayOrder int    `json:"display_order"`
}

type MockTestResponse struct {
    ID              string `json:"id"`
    BatchID         string `json:"batch_id"`
    Title           string `json:"title"`
    DurationMinutes int    `json:"duration_minutes"`
    TotalQuestions  int    `json:"total_questions"`
}

type PYQResponse struct {
    ID         string `json:"id"`
    BatchID    string `json:"batch_id"`
    ExamName   string `json:"exam_name"`
    Year       int    `json:"year"`
    SubjectTag string `json:"subject_tag"`
    FileURL    string `json:"file_url"`
}
