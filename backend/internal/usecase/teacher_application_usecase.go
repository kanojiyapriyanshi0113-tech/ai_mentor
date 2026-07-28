package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

type SubmitTeacherApplicationInput struct {
	UserID          string
	FullName        string
	Email           string
	Phone           string
	Qualification   string
	ExperienceYears int
	ExamExpertise   string
	Subjects        string
	About           string
	ResumeURL       string
	DegreeURL       string
	GovtIDURL       string
	PhotoURL        string
	DemoVideoURL    string
	ExpectedSalary  int
}

// TeacherApplicationUsecase drives the Become-a-Teacher application
// lifecycle: student submission, self status lookup, and admin review
// (approve / reject / request changes). Approval promotes the underlying
// user account to role=teacher, is_approved=true.
type TeacherApplicationUsecase interface {
	Submit(ctx context.Context, in SubmitTeacherApplicationInput) (*entity.TeacherApplication, error)
	GetMine(ctx context.Context, userID string) (*entity.TeacherApplication, error)
	List(ctx context.Context, status string, limit, offset int) ([]entity.TeacherApplication, error)
	Get(ctx context.Context, id string) (*entity.TeacherApplication, error)
	Approve(ctx context.Context, id string, reviewerID string, note string) error
	Reject(ctx context.Context, id string, reviewerID string, note string) error
	RequestChanges(ctx context.Context, id string, reviewerID string, note string) error
}

type teacherApplicationUsecase struct {
	appRepo  repository.TeacherApplicationRepository
	userRepo repository.UserRepository
}

func NewTeacherApplicationUsecase(appRepo repository.TeacherApplicationRepository, userRepo repository.UserRepository) TeacherApplicationUsecase {
	return &teacherApplicationUsecase{appRepo: appRepo, userRepo: userRepo}
}

func (uc *teacherApplicationUsecase) Submit(ctx context.Context, in SubmitTeacherApplicationInput) (*entity.TeacherApplication, error) {
	userID, err := uuid.Parse(in.UserID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	open, err := uc.appRepo.HasOpenApplication(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("check open application: %w", err)
	}
	if open {
		return nil, apperror.ErrTeacherApplicationOpenExists
	}

	a := &entity.TeacherApplication{
		UserID:          in.UserID,
		FullName:        in.FullName,
		Email:           in.Email,
		Phone:           in.Phone,
		Qualification:   in.Qualification,
		ExperienceYears: in.ExperienceYears,
		ExamExpertise:   in.ExamExpertise,
		Subjects:        in.Subjects,
		About:           in.About,
		ResumeURL:       in.ResumeURL,
		DegreeURL:       in.DegreeURL,
		GovtIDURL:       in.GovtIDURL,
		PhotoURL:        in.PhotoURL,
		DemoVideoURL:    in.DemoVideoURL,
		ExpectedSalary:  in.ExpectedSalary,
		Status:          entity.ApplicationPending,
	}
	if err := uc.appRepo.Create(ctx, a); err != nil {
		return nil, fmt.Errorf("submit teacher application: %w", err)
	}
	return a, nil
}

func (uc *teacherApplicationUsecase) GetMine(ctx context.Context, userID string) (*entity.TeacherApplication, error) {
	uid, err := uuid.Parse(userID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	return uc.appRepo.FindLatestByUserID(ctx, uid)
}

func (uc *teacherApplicationUsecase) List(ctx context.Context, status string, limit, offset int) ([]entity.TeacherApplication, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return uc.appRepo.List(ctx, status, limit, offset)
}

func (uc *teacherApplicationUsecase) Get(ctx context.Context, id string) (*entity.TeacherApplication, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}
	return uc.appRepo.FindByID(ctx, uid)
}

func (uc *teacherApplicationUsecase) Approve(ctx context.Context, id string, reviewerID string, note string) error {
	app, reviewer, err := uc.loadForReview(ctx, id, reviewerID)
	if err != nil {
		return err
	}
	appUserID, err := uuid.Parse(app.UserID)
	if err != nil {
		return apperror.ErrInvalidInput
	}
	// Promote the account: role=teacher, is_approved=true (existing column).
	if err := uc.userRepo.UpdateRole(ctx, appUserID, entity.RoleTeacher); err != nil {
		return fmt.Errorf("promote user to teacher: %w", err)
	}
	appID, _ := uuid.Parse(app.ID)
	if err := uc.appRepo.UpdateStatus(ctx, appID, entity.ApplicationApproved, note, reviewer); err != nil {
		return fmt.Errorf("approve teacher application: %w", err)
	}
	return nil
}

func (uc *teacherApplicationUsecase) Reject(ctx context.Context, id string, reviewerID string, note string) error {
	app, reviewer, err := uc.loadForReview(ctx, id, reviewerID)
	if err != nil {
		return err
	}
	appID, _ := uuid.Parse(app.ID)
	return uc.appRepo.UpdateStatus(ctx, appID, entity.ApplicationRejected, note, reviewer)
}

func (uc *teacherApplicationUsecase) RequestChanges(ctx context.Context, id string, reviewerID string, note string) error {
	app, reviewer, err := uc.loadForReview(ctx, id, reviewerID)
	if err != nil {
		return err
	}
	appID, _ := uuid.Parse(app.ID)
	return uc.appRepo.UpdateStatus(ctx, appID, entity.ApplicationChangesRequested, note, reviewer)
}

func (uc *teacherApplicationUsecase) loadForReview(ctx context.Context, id string, reviewerID string) (*entity.TeacherApplication, uuid.UUID, error) {
	appUUID, err := uuid.Parse(id)
	if err != nil {
		return nil, uuid.Nil, apperror.ErrInvalidInput
	}
	reviewer, err := uuid.Parse(reviewerID)
	if err != nil {
		return nil, uuid.Nil, apperror.ErrInvalidInput
	}
	app, err := uc.appRepo.FindByID(ctx, appUUID)
	if err != nil {
		return nil, uuid.Nil, err
	}
	return app, reviewer, nil
}