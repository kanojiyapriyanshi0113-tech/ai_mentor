package dto

import "time"

type SubmitTeacherApplicationRequest struct {
	FullName        string `json:"full_name" binding:"required"`
	Email           string `json:"email" binding:"required,email"`
	Phone           string `json:"phone" binding:"required"`
	Qualification   string `json:"qualification"`
	ExperienceYears int    `json:"experience_years"`
	ExamExpertise   string `json:"exam_expertise"`
	Subjects        string `json:"subjects"`
	About           string `json:"about"`
	ResumeURL       string `json:"resume_url"`
	DegreeURL       string `json:"degree_url"`
	GovtIDURL       string `json:"govt_id_url"`
	PhotoURL        string `json:"photo_url"`
	DemoVideoURL    string `json:"demo_video_url"`
	ExpectedSalary  int    `json:"expected_salary"`
}

type ReviewTeacherApplicationRequest struct {
	Note string `json:"note"`
}

type TeacherApplicationResponse struct {
	ID              string     `json:"id"`
	UserID          string     `json:"user_id"`
	FullName        string     `json:"full_name"`
	Email           string     `json:"email"`
	Phone           string     `json:"phone"`
	Qualification   string     `json:"qualification"`
	ExperienceYears int        `json:"experience_years"`
	ExamExpertise   string     `json:"exam_expertise"`
	Subjects        string     `json:"subjects"`
	About           string     `json:"about"`
	ResumeURL       string     `json:"resume_url"`
	DegreeURL       string     `json:"degree_url"`
	GovtIDURL       string     `json:"govt_id_url"`
	PhotoURL        string     `json:"photo_url"`
	DemoVideoURL    string     `json:"demo_video_url"`
	ExpectedSalary  int        `json:"expected_salary"`
	Status          string     `json:"status"`
	AdminNote       string     `json:"admin_note"`
	ReviewedBy      string     `json:"reviewed_by,omitempty"`
	ReviewedAt      *time.Time `json:"reviewed_at,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}