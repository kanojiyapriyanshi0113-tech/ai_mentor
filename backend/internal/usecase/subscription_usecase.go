package usecase

import (
"context"
"fmt"
"math"
"time"

"github.com/google/uuid"

"ai-mentor-backend/internal/domain/apperror"
"ai-mentor-backend/internal/domain/entity"
"ai-mentor-backend/internal/domain/repository"
)

type PlanFeatures map[string]int

type SubscriptionDetail struct {
Plan         entity.Plan
Subscription entity.Subscription
DaysLeft     int
Features     PlanFeatures
}

type SubscriptionSummary struct {
CurrentPlan          string
TrialDaysLeft        int
AIQuestionsRemaining int
ChaptersRemaining    int
VideosRemaining      int
PDFNotesRemaining    int
MockTestsRemaining   int
}

type SubscriptionUsecase interface {
GetCurrentSubscription(ctx context.Context, userID uuid.UUID) (*SubscriptionDetail, error)
GetSubscriptionSummary(ctx context.Context, userID uuid.UUID) (*SubscriptionSummary, error)
ListPlans(ctx context.Context) ([]entity.Plan, error)
GetFeatures(ctx context.Context, userID uuid.UUID) (PlanFeatures, error)
UpgradePlan(ctx context.Context, userID uuid.UUID, planCode string) (*SubscriptionDetail, error)
CheckDailyLimit(ctx context.Context, userID uuid.UUID, featureKey string) error
RecordDailyUsage(ctx context.Context, userID uuid.UUID, featureKey string) error
CheckLifetimeLimit(ctx context.Context, userID uuid.UUID, featureKey string) error
CheckOrdinalLimit(ctx context.Context, userID uuid.UUID, featureKey string, ordinal int) error
}

type subscriptionUsecase struct {
subRepo      repository.SubscriptionRepository
planRepo     repository.PlanRepository
featureRepo  repository.SubscriptionFeatureRepository
usageRepo    repository.UserUsageRepository
userRepo     repository.UserRepository
progressRepo repository.UserProgressRepository
}

func NewSubscriptionUsecase(
subRepo repository.SubscriptionRepository,
planRepo repository.PlanRepository,
featureRepo repository.SubscriptionFeatureRepository,
usageRepo repository.UserUsageRepository,
userRepo repository.UserRepository,
progressRepo repository.UserProgressRepository,
) SubscriptionUsecase {
return &subscriptionUsecase{
subRepo: subRepo, planRepo: planRepo, featureRepo: featureRepo,
usageRepo: usageRepo, userRepo: userRepo, progressRepo: progressRepo,
}
}

func (uc *subscriptionUsecase) ensureSubscription(ctx context.Context, userID uuid.UUID) (*entity.Subscription, error) {
sub, err := uc.subRepo.FindByUserID(ctx, userID)
if err != nil {
return nil, fmt.Errorf("find subscription: %w", err)
}
if sub != nil {
return sub, nil
}

user, err := uc.userRepo.FindByID(ctx, userID)
if err != nil {
return nil, fmt.Errorf("find user: %w", err)
}
if user == nil {
return nil, apperror.ErrUserNotFound
}

plan, err := uc.planRepo.FindByCode(ctx, "free_trial")
if err != nil {
return nil, fmt.Errorf("find free_trial plan: %w", err)
}
if plan == nil {
return nil, apperror.ErrPlanNotFound
}

newSub := &entity.Subscription{
UserID: userID, PlanID: plan.ID, Status: "active",
StartedAt: user.TrialStartDate, ExpiresAt: user.TrialEndDate,
}
if err := uc.subRepo.Upsert(ctx, newSub); err != nil {
return nil, fmt.Errorf("create default subscription: %w", err)
}
return uc.subRepo.FindByUserID(ctx, userID)
}

func (uc *subscriptionUsecase) loadFeatures(ctx context.Context, planID int) (PlanFeatures, error) {
rows, err := uc.featureRepo.ListByPlanID(ctx, planID)
if err != nil {
return nil, fmt.Errorf("list features: %w", err)
}
features := make(PlanFeatures, len(rows))
for _, r := range rows {
features[r.FeatureKey] = r.FeatureLimit
}
return features, nil
}

func (uc *subscriptionUsecase) GetCurrentSubscription(ctx context.Context, userID uuid.UUID) (*SubscriptionDetail, error) {
sub, err := uc.ensureSubscription(ctx, userID)
if err != nil {
return nil, err
}
plan, err := uc.planRepo.FindByID(ctx, sub.PlanID)
if err != nil {
return nil, fmt.Errorf("find plan: %w", err)
}
if plan == nil {
return nil, apperror.ErrPlanNotFound
}
features, err := uc.loadFeatures(ctx, sub.PlanID)
if err != nil {
return nil, err
}

daysLeft := 0
if remainingTime := time.Until(sub.ExpiresAt); remainingTime > 0 {
daysLeft = int(math.Ceil(remainingTime.Hours() / 24))
}

return &SubscriptionDetail{Plan: *plan, Subscription: *sub, DaysLeft: daysLeft, Features: features}, nil
}

func remainingCount(limit, used int) int {
if limit == -1 {
return -1
}
r := limit - used
if r < 0 {
return 0
}
return r
}

func (uc *subscriptionUsecase) GetSubscriptionSummary(ctx context.Context, userID uuid.UUID) (*SubscriptionSummary, error) {
detail, err := uc.GetCurrentSubscription(ctx, userID)
if err != nil {
return nil, err
}

today := time.Now().UTC().Truncate(24 * time.Hour)

aiUsed, err := uc.usageRepo.GetUsage(ctx, userID, today, "ai_chat_daily_limit")
if err != nil {
return nil, fmt.Errorf("get ai usage: %w", err)
}
mockUsed, err := uc.usageRepo.GetUsage(ctx, userID, lifetimeUsageDate, "max_mock_tests")
if err != nil {
return nil, fmt.Errorf("get mock test usage: %w", err)
}
chaptersUsed, err := uc.progressRepo.CountCompleted(ctx, userID, "max_chapters")
if err != nil {
return nil, fmt.Errorf("get chapters progress: %w", err)
}
videosUsed, err := uc.progressRepo.CountCompleted(ctx, userID, "max_lectures")
if err != nil {
return nil, fmt.Errorf("get videos progress: %w", err)
}
notesUsed, err := uc.progressRepo.CountCompleted(ctx, userID, "max_notes")
if err != nil {
return nil, fmt.Errorf("get notes progress: %w", err)
}

return &SubscriptionSummary{
CurrentPlan:          detail.Plan.Name,
TrialDaysLeft:        detail.DaysLeft,
AIQuestionsRemaining: remainingCount(detail.Features["ai_chat_daily_limit"], aiUsed),
ChaptersRemaining:    remainingCount(detail.Features["max_chapters"], chaptersUsed),
VideosRemaining:      remainingCount(detail.Features["max_lectures"], videosUsed),
PDFNotesRemaining:    remainingCount(detail.Features["max_notes"], notesUsed),
MockTestsRemaining:   remainingCount(detail.Features["max_mock_tests"], mockUsed),
}, nil
}

func (uc *subscriptionUsecase) ListPlans(ctx context.Context) ([]entity.Plan, error) {
return uc.planRepo.ListAll(ctx)
}

func (uc *subscriptionUsecase) GetFeatures(ctx context.Context, userID uuid.UUID) (PlanFeatures, error) {
sub, err := uc.ensureSubscription(ctx, userID)
if err != nil {
return nil, err
}
return uc.loadFeatures(ctx, sub.PlanID)
}

func (uc *subscriptionUsecase) UpgradePlan(ctx context.Context, userID uuid.UUID, planCode string) (*SubscriptionDetail, error) {
plan, err := uc.planRepo.FindByCode(ctx, planCode)
if err != nil {
return nil, fmt.Errorf("find plan: %w", err)
}
if plan == nil {
return nil, apperror.ErrPlanNotFound
}

now := time.Now()
newSub := &entity.Subscription{
UserID: userID, PlanID: plan.ID, Status: "active",
StartedAt: now, ExpiresAt: now.AddDate(0, 0, plan.DurationDays),
}
if err := uc.subRepo.Upsert(ctx, newSub); err != nil {
return nil, fmt.Errorf("upgrade subscription: %w", err)
}
return uc.GetCurrentSubscription(ctx, userID)
}

func (uc *subscriptionUsecase) featureLimit(ctx context.Context, userID uuid.UUID, featureKey string) (int, error) {
sub, err := uc.ensureSubscription(ctx, userID)
if err != nil {
return 0, err
}
limit, err := uc.featureRepo.GetLimit(ctx, sub.PlanID, featureKey)
if err != nil {
return 0, fmt.Errorf("get feature limit: %w", err)
}
return limit, nil
}

var lifetimeUsageDate = time.Date(2000, 1, 1, 0, 0, 0, 0, time.UTC)

func (uc *subscriptionUsecase) CheckDailyLimit(ctx context.Context, userID uuid.UUID, featureKey string) error {
return uc.checkOnly(ctx, userID, featureKey, time.Now().UTC().Truncate(24*time.Hour))
}

func (uc *subscriptionUsecase) RecordDailyUsage(ctx context.Context, userID uuid.UUID, featureKey string) error {
usageDate := time.Now().UTC().Truncate(24 * time.Hour)
if err := uc.usageRepo.IncrementUsage(ctx, userID, usageDate, featureKey); err != nil {
return fmt.Errorf("record daily usage: %w", err)
}
return nil
}

func (uc *subscriptionUsecase) checkOnly(ctx context.Context, userID uuid.UUID, featureKey string, usageDate time.Time) error {
limit, err := uc.featureLimit(ctx, userID, featureKey)
if err != nil {
return err
}
if limit == 0 {
return apperror.ErrFeatureLimitExceeded
}
if limit == -1 {
return nil
}
used, err := uc.usageRepo.GetUsage(ctx, userID, usageDate, featureKey)
if err != nil {
return fmt.Errorf("get usage: %w", err)
}
if used >= limit {
return apperror.ErrFeatureLimitExceeded
}
return nil
}

func (uc *subscriptionUsecase) CheckLifetimeLimit(ctx context.Context, userID uuid.UUID, featureKey string) error {
return uc.checkAndIncrement(ctx, userID, featureKey, lifetimeUsageDate)
}

func (uc *subscriptionUsecase) checkAndIncrement(ctx context.Context, userID uuid.UUID, featureKey string, usageDate time.Time) error {
limit, err := uc.featureLimit(ctx, userID, featureKey)
if err != nil {
return err
}
if limit == 0 {
return apperror.ErrFeatureLimitExceeded
}
if limit == -1 {
return uc.usageRepo.IncrementUsage(ctx, userID, usageDate, featureKey)
}

used, err := uc.usageRepo.GetUsage(ctx, userID, usageDate, featureKey)
if err != nil {
return fmt.Errorf("get usage: %w", err)
}
if used >= limit {
return apperror.ErrFeatureLimitExceeded
}
return uc.usageRepo.IncrementUsage(ctx, userID, usageDate, featureKey)
}

func (uc *subscriptionUsecase) CheckOrdinalLimit(ctx context.Context, userID uuid.UUID, featureKey string, ordinal int) error {
limit, err := uc.featureLimit(ctx, userID, featureKey)
if err != nil {
return err
}
if limit == -1 {
return nil
}
if ordinal > limit {
return apperror.ErrFeatureLimitExceeded
}
return nil
}
