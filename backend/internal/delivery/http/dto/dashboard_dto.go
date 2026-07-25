package dto

// DashboardResponse is the payload returned by GET /api/dashboard.
type DashboardResponse struct {
    Name             string      `json:"name"`
    Email            string      `json:"email"`
    Premium          bool        `json:"premium"`
    TrialActive      bool        `json:"trial_active"`
    TrialDaysLeft    int         `json:"trial_days_left"`
    SelectedExam     *ExamOption `json:"selected_exam"`
    StudyStreak      int         `json:"study_streak"`
    DailyGoal        int         `json:"daily_goal"`
    CompletedToday   bool        `json:"completed_today"`
    ContinueLearning *string     `json:"continue_learning"`
}
