package dto

import "time"

type BatchResponse struct {
	ID          string    `json:"id"`
	ExamID      int       `json:"exam_id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Thumbnail   string    `json:"thumbnail"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
}

type SubjectResponse struct {
	ID           string `json:"id"`
	BatchID      string `json:"batch_id"`
	Name         string `json:"name"`
	Icon         string `json:"icon"`
	DisplayOrder int    `json:"display_order"`
}

type ChapterResponse struct {
	ID           string `json:"id"`
	SubjectID    string `json:"subject_id"`
	Title        string `json:"title"`
	Description  string `json:"description"`
	DisplayOrder int    `json:"display_order"`
}

type LectureResponse struct {
	ID              string `json:"id"`
	ChapterID       string `json:"chapter_id"`
	Title           string `json:"title"`
	Description     string `json:"description"`
	DurationMinutes int    `json:"duration_minutes"`
	VideoURL        string `json:"video_url"`
	IsPreview       bool   `json:"is_preview"`
	DisplayOrder    int    `json:"display_order"`
}