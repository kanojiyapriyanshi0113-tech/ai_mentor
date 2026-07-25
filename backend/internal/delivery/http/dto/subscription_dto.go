package dto

import "time"

type PlanResponse struct {
Code         string `json:"code"`
Name         string `json:"name"`
PricePaise   int    `json:"price_paise"`
DurationDays int    `json:"duration_days"`
IsTrial      bool   `json:"is_trial"`
}

type SubscriptionResponse struct {
PlanCode  string         `json:"plan_code"`
PlanName  string         `json:"plan_name"`
Status    string         `json:"status"`
IsTrial   bool           `json:"is_trial"`
StartedAt time.Time      `json:"started_at"`
ExpiresAt time.Time      `json:"expires_at"`
DaysLeft  int            `json:"days_left"`
Features  map[string]int `json:"features"`
}

// SubscriptionSummaryResponse is the response shape for GET /api/subscription.
type SubscriptionSummaryResponse struct {
CurrentPlan          string `json:"current_plan"`
TrialDaysLeft        int    `json:"trial_days_left"`
AIQuestionsRemaining int    `json:"ai_questions_remaining"`
ChaptersRemaining    int    `json:"chapters_remaining"`
VideosRemaining      int    `json:"videos_remaining"`
PDFNotesRemaining    int    `json:"pdf_notes_remaining"`
MockTestsRemaining   int    `json:"mock_tests_remaining"`
}

type UpgradeSubscriptionRequest struct {
PlanCode string `json:"plan_code" validate:"required"`
}
