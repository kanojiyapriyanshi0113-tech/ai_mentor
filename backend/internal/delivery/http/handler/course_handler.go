package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"ai-mentor-backend/internal/delivery/http/dto"
	"ai-mentor-backend/internal/delivery/http/middleware"
	"ai-mentor-backend/internal/delivery/http/response"
	"ai-mentor-backend/internal/domain/apperror"
	"ai-mentor-backend/internal/domain/entity"
	"ai-mentor-backend/internal/usecase"
)

type CourseHandler struct {
	courseUsecase usecase.CourseUsecase
}

func NewCourseHandler(courseUsecase usecase.CourseUsecase) *CourseHandler {
	return &CourseHandler{courseUsecase: courseUsecase}
}

func toBatchDTO(b entity.Batch) dto.BatchResponse {
	return dto.BatchResponse{
		ID:          b.ID,
		ExamID:      b.ExamID,
		Title:       b.Title,
		Description: b.Description,
		Thumbnail:   b.Thumbnail,
		IsActive:    b.IsActive,
		CreatedAt:   b.CreatedAt,
	}
}

func toSubjectDTO(s entity.Subject) dto.SubjectResponse {
	return dto.SubjectResponse{
		ID:           s.ID,
		BatchID:      s.BatchID,
		Name:         s.Name,
		Icon:         s.Icon,
		DisplayOrder: s.DisplayOrder,
	}
}

func toChapterDTO(c entity.Chapter) dto.ChapterResponse {
	return dto.ChapterResponse{
		ID:           c.ID,
		SubjectID:    c.SubjectID,
		Title:        c.Title,
		Description:  c.Description,
		DisplayOrder: c.DisplayOrder,
	}
}

func toLectureDTO(l entity.Lecture) dto.LectureResponse {
	return dto.LectureResponse{
		ID:              l.ID,
		ChapterID:       l.ChapterID,
		Title:           l.Title,
		Description:     l.Description,
		DurationMinutes: l.DurationMinutes,
		VideoURL:        l.VideoURL,
		IsPreview:       l.IsPreview,
		DisplayOrder:    l.DisplayOrder,
	}
}

func (h *CourseHandler) ListBatches(c *gin.Context) {
	userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

	batches, err := h.courseUsecase.ListBatches(c.Request.Context(), userID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}
	out := make([]dto.BatchResponse, 0, len(batches))
	for _, b := range batches {
		out = append(out, toBatchDTO(b))
	}
	response.Success(c, http.StatusOK, out, "")
}

func (h *CourseHandler) GetBatch(c *gin.Context) {
	batchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid batch id")
		return
	}

	batch, err := h.courseUsecase.GetBatch(c.Request.Context(), batchID)
	if err != nil {
		if errors.Is(err, apperror.ErrBatchNotFound) {
			response.Error(c, http.StatusNotFound, "BATCH_NOT_FOUND", "Batch not found")
			return
		}
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}
	response.Success(c, http.StatusOK, toBatchDTO(*batch), "")
}

func (h *CourseHandler) ListSubjects(c *gin.Context) {
	batchID, err := uuid.Parse(c.Param("batchId"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid batch id")
		return
	}

	subjects, err := h.courseUsecase.ListSubjects(c.Request.Context(), batchID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}
	out := make([]dto.SubjectResponse, 0, len(subjects))
	for _, s := range subjects {
		out = append(out, toSubjectDTO(s))
	}
	response.Success(c, http.StatusOK, out, "")
}

func (h *CourseHandler) ListChapters(c *gin.Context) {
	subjectID, err := uuid.Parse(c.Param("subjectId"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid subject id")
		return
	}

	chapters, err := h.courseUsecase.ListChapters(c.Request.Context(), subjectID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}
	out := make([]dto.ChapterResponse, 0, len(chapters))
	for _, ch := range chapters {
		out = append(out, toChapterDTO(ch))
	}
	response.Success(c, http.StatusOK, out, "")
}

func (h *CourseHandler) ListLectures(c *gin.Context) {
	chapterID, err := uuid.Parse(c.Param("chapterId"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid chapter id")
		return
	}

	lectures, err := h.courseUsecase.ListLectures(c.Request.Context(), chapterID)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
		return
	}
	out := make([]dto.LectureResponse, 0, len(lectures))
	for _, l := range lectures {
		out = append(out, toLectureDTO(l))
	}
	response.Success(c, http.StatusOK, out, "")
}
