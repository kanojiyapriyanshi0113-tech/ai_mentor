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
    "ai-mentor-backend/internal/usecase"
)

type CourseProgressHandler struct {
    progressUC usecase.CourseProgressUsecase
}

func NewCourseProgressHandler(progressUC usecase.CourseProgressUsecase) *CourseProgressHandler {
    return &CourseProgressHandler{progressUC: progressUC}
}

func toLectureSummaryDTO(s *usecase.LectureSummary) *dto.LectureSummaryResponse {
    if s == nil {
        return nil
    }
    return &dto.LectureSummaryResponse{
        LectureID:    s.LectureID.String(),
        LectureTitle: s.LectureTitle,
        ChapterID:    s.ChapterID.String(),
        ChapterTitle: s.ChapterTitle,
    }
}

// CompleteLecture marks a lecture as completed for the current user.
func (h *CourseProgressHandler) CompleteLecture(c *gin.Context) {
    userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

    lectureID, err := uuid.Parse(c.Param("lectureId"))
    if err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid lecture id")
        return
    }

    if err := h.progressUC.CompleteLecture(c.Request.Context(), userID, lectureID); err != nil {
        if errors.Is(err, apperror.ErrLectureNotFound) {
            response.Error(c, http.StatusNotFound, "LECTURE_NOT_FOUND", "Lecture not found")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }
    response.Success(c, http.StatusOK, nil, "Lecture marked complete")
}

// GetBatchProgress returns completed chapters/lectures, progress percent,
// last watched lecture, and the next lecture to continue with.
func (h *CourseProgressHandler) GetBatchProgress(c *gin.Context) {
    userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

    batchID, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid batch id")
        return
    }

    progress, err := h.progressUC.GetBatchProgress(c.Request.Context(), userID, batchID)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
        return
    }

    out := dto.BatchProgressResponse{
        CompletedLectures: progress.CompletedLectures,
        TotalLectures:     progress.TotalLectures,
        CompletedChapters: progress.CompletedChapters,
        TotalChapters:     progress.TotalChapters,
        ProgressPercent:   progress.ProgressPercent,
        LastWatched:       toLectureSummaryDTO(progress.LastWatched),
        ContinueLearning:  toLectureSummaryDTO(progress.ContinueLearning),
    }
    response.Success(c, http.StatusOK, out, "")
}
