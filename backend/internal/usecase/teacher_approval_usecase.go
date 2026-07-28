package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

// TeacherApprovalUsecase drives the admin Teacher Approval queue: reviewing
// pending "Become a Teacher" applications and suspending/reactivating
// existing teacher accounts.
//
//   - Approve promotes the applicant's account to role=teacher and marks
//     the application approved.
//   - Reject marks the application rejected without touching the account.
//   - Only applications still in "pending" or "changes_requested" can be
//     approved/rejected; anything already reviewed returns
//     apperror.ErrTeacherApplicationNotEditable.
type TeacherApprovalUsecase interface {
	PendingApplications(ctx context.Context, limit, offset int) ([]entity.TeacherApplication, int, error)
	Approve(ctx context.Context, applicationID string, reviewerID string, note string) error
	Reject(ctx context.Context, applicationID string, reviewerID string, note string) error
	SuspendTeacher(ctx context.Context, teacherID string, suspend bool) error
}

type teacherApprovalUsecase struct {
	repo     repository.TeacherApprovalFullRepository
	userRepo repository.UserRepository
}

func NewTeacherApprovalUsecase(repo repository.TeacherApprovalFullRepository, userRepo repository.UserRepository) TeacherApprovalUsecase {
	return &teacherApprovalUsecase{repo: repo, userRepo: userRepo}
}

func (uc *teacherApprovalUsecase) PendingApplications(ctx context.Context, limit, offset int) ([]entity.TeacherApplication, int, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}
	return uc.repo.ListPendingApplications(ctx, limit, offset)
}

func (uc *teacherApprovalUsecase) Approve(ctx context.Context, applicationID string, reviewerID string, note string) error {
	app, reviewer, err := uc.loadForReview(ctx, applicationID, reviewerID)
	if err != nil {
		return err
	}
	appUserID, err := uuid.Parse(app.UserID)
	if err != nil {
		return apperror.ErrInvalidInput
	}
	// Promote the account: role=teacher (existing "Become a Teacher" flow).
	if err := uc.userRepo.UpdateRole(ctx, appUserID, entity.RoleTeacher); err != nil {
		return fmt.Errorf("promote user to teacher: %w", err)
	}
	appID, _ := uuid.Parse(app.ID)
	if err := uc.repo.UpdateStatus(ctx, appID, entity.ApplicationApproved, note, reviewer); err != nil {
		return fmt.Errorf("approve teacher application: %w", err)
	}
	return nil
}

func (uc *teacherApprovalUsecase) Reject(ctx context.Context, applicationID string, reviewerID string, note string) error {
	app, reviewer, err := uc.loadForReview(ctx, applicationID, reviewerID)
	if err != nil {
		return err
	}
	appID, _ := uuid.Parse(app.ID)
	if err := uc.repo.UpdateStatus(ctx, appID, entity.ApplicationRejected, note, reviewer); err != nil {
		return fmt.Errorf("reject teacher application: %w", err)
	}
	return nil
}

func (uc *teacherApprovalUsecase) SuspendTeacher(ctx context.Context, teacherID string, suspend bool) error {
	id, err := uuid.Parse(teacherID)
	if err != nil {
		return apperror.ErrInvalidInput
	}
	if _, err := uc.repo.FindTeacherByID(ctx, id); err != nil {
		return err
	}
	if err := uc.repo.SetTeacherSuspension(ctx, id, suspend); err != nil {
		return fmt.Errorf("set teacher suspension: %w", err)
	}
	return nil
}

// loadForReview resolves the application and reviewer ids and guards
// against re-reviewing an application that's already been decided.
func (uc *teacherApprovalUsecase) loadForReview(ctx context.Context, applicationID string, reviewerID string) (*entity.TeacherApplication, uuid.UUID, error) {
	appUUID, err := uuid.Parse(applicationID)
	if err != nil {
		return nil, uuid.Nil, apperror.ErrInvalidInput
	}
	reviewer, err := uuid.Parse(reviewerID)
	if err != nil {
		return nil, uuid.Nil, apperror.ErrInvalidInput
	}
	app, err := uc.repo.FindByID(ctx, appUUID)
	if err != nil {
		return nil, uuid.Nil, err
	}
	if app.Status != entity.ApplicationPending && app.Status != entity.ApplicationChangesRequested {
		return nil, uuid.Nil, apperror.ErrTeacherApplicationNotEditable
	}
	return app, reviewer, nil
}
