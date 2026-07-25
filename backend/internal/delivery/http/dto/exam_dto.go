package dto

// ExamOption represents a single selectable exam.
type ExamOption struct {
	ID       int    `json:"id"`
	Code     string `json:"code"`
	Name     string `json:"name"`
	Category string `json:"category"`
}

// SelectExamRequest is the payload for POST /api/exams/select.
type SelectExamRequest struct {
	ExamID int `json:"exam_id" validate:"required"`
}

// SelectExamResponse confirms the selection.
type SelectExamResponse struct {
	ExamID   int    `json:"exam_id"`
	Code     string `json:"code"`
	Name     string `json:"name"`
	Category string `json:"category"`
}
