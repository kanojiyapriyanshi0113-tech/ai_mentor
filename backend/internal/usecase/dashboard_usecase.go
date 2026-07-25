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

// DashboardData is the aggregate result for the dashboard screen.
type DashboardData struct {
    User          *entity.User
    SelectedExam  *entity.Exam
    TrialDaysLeft int
    StudyStreak      int
    DailyGoal        int
    CompletedToday   bool
    ContinueLearning *string
}

type DashboardUsecase interface {
    GetDashboard(ctx context.Context, userID uuid.UUID) (*DashboardData, error)
}

type dashboardUsecase struct {
    userRepo repository.UserRepository
    examRepo repository.ExamRepository
}

func NewDashboardUsecase(userRepo repository.UserRepository, examRepo repository.ExamRepository) DashboardUsecase {
    return &dashboardUsecase{userRepo: userRepo, examRepo: examRepo}
}

func (uc *dashboardUsecase) GetDashboard(ctx context.Context, userID uuid.UUID) (*DashboardData, error) {
    user, err := uc.userRepo.FindByID(ctx, userID)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    if user == nil {
        return nil, apperror.ErrUserNotFound
    }

    exam, err := uc.examRepo.FindSelectedExamByUserID(ctx, userID)
    if err != nil {
        return nil, fmt.Errorf("find selected exam: %w", err)
    }

    daysLeft := 0
    if !user.Premium {
        remaining := time.Until(user.TrialEndDate)
        if remaining > 0 {
            daysLeft = int(math.Ceil(remaining.Hours() / 24))
        }
    }

    return &DashboardData{
        User:             user,
        SelectedExam:     exam,
        TrialDaysLeft:    daysLeft,
        StudyStreak:      0,
        DailyGoal:        0,
        CompletedToday:   false,
        ContinueLearning: nil,
    }, nil
}
