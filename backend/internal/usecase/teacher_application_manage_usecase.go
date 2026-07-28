package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/domain/repository"
)

// UpdateTeacherApplicationInput carries the editable fields for an
// in-review application. Same shape as SubmitTeacherApplicationInput minus
// UserID, which is taken from the authenticated requester instead.
type UpdateTeacherApplicationInput struct {
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

// TeacherApplicationManageUsecase covers the applicant self-service actions
// (view own is already on TeacherApplicationUsecase; this adds edit and
// withdraw) plus an admin search+paginated listing.
type TeacherApplicationManageUsecase interface {
	Update(ctx context.Context, userID string, in UpdateTeacherApplicationInput) (*entity.TeacherApplication, error)
	Cancel(ctx context.Context, userID string) error
	SearchList(ctx context.Context, status string, search string, limit, offset int) ([]entity.TeacherApplication, int, error)
}

type teacherApplicationManageUsecase struct {
	repo repository.TeacherApplicationFullRepository
}

func NewTeacherApplicationManageUsecase(repo repository.TeacherApplicationFullRepository) TeacherApplicationManageUsecase {
	return &teacherApplicationManageUsecase{repo: repo}
}

func (uc *teacherApplicationManageUsecase) Update(ctx context.Context, userID string, in UpdateTeacherApplicationInput) (*entity.TeacherApplication, error) {
	if in.FullName == "" || in.Email == "" || in.Phone == "" {
		return nil, apperror.ErrInvalidInput
	}
	uid, err := uuid.Parse(userID)
	if err != nil {
		return nil, apperror.ErrInvalidInput
	}

	existing, err := uc.repo.FindLatestByUserID(ctx, uid)
	if err != nil {
		return nil, err
	}

	updated := &entity.TeacherApplication{
		ID: existing.ID, FullName: in.FullName, Email: in.Email, Phone: in.Phone,
		Qualification: in.Qualification, ExperienceYears: in.ExperienceYears, ExamExpertise: in.ExamExpertise,
		Subjects: in.Subjects, About: in.About, ResumeURL: in.ResumeURL, DegreeURL: in.DegreeURL,
		GovtIDURL: in.GovtIDURL, PhotoURL: in.PhotoURL, DemoVideoURL: in.DemoVideoURL, ExpectedSalary: in.ExpectedSalary,
	}
	if err := uc.repo.Update(ctx, updated, uid); err != nil {
		return nil, err
	}
	return uc.repo.FindByID(ctx, uuid.MustParse(existing.ID))
}

func (uc *teacherApplicationManageUsecase) Cancel(ctx context.Context, userID string) error {
	uid, err := uuid.Parse(userID)
	if err != nil {
		return apperror.ErrInvalidInput
	}

	existing, err := uc.repo.FindLatestByUserID(ctx, uid)
	if err != nil {
		return err
	}

	appUUID, err := uuid.Parse(existing.ID)
	if err != nil {
		return apperror.ErrInvalidInput
	}
	if err := uc.repo.Cancel(ctx, appUUID, uid); err != nil {
		return fmt.Errorf("cancel teacher application: %w", err)
	}
	return nil
}

func (uc *teacherApplicationManageUsecase) SearchList(ctx context.Context, status string, search string, limit, offset int) ([]entity.TeacherApplication, int, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return uc.repo.SearchList(ctx, status, search, limit, offset)
}
