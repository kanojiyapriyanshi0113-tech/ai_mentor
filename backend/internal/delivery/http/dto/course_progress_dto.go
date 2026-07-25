package dto

type LectureSummaryResponse struct {
    LectureID    string `json:"lecture_id"`
    LectureTitle string `json:"lecture_title"`
    ChapterID    string `json:"chapter_id"`
    ChapterTitle string `json:"chapter_title"`
}

type BatchProgressResponse struct {
    CompletedLectures int                     `json:"completed_lectures"`
    TotalLectures     int                     `json:"total_lectures"`
    CompletedChapters int                     `json:"completed_chapters"`
    TotalChapters     int                     `json:"total_chapters"`
    ProgressPercent   float64                 `json:"progress_percent"`
    LastWatched       *LectureSummaryResponse `json:"last_watched"`
    ContinueLearning  *LectureSummaryResponse `json:"continue_learning"`
}
