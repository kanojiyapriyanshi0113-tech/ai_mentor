package dto

type UpdateTeacherApplicationRequest struct {
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
