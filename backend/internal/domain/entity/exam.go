package entity

// Exam represents a supported competitive exam.
type Exam struct {
	ID       int
	Code     string
	Name     string
	Category string
}

// UserExam links a user to a selected exam.
type UserExam struct {
	ID         string
	UserID     string
	ExamID     int
	SelectedAt string
}
