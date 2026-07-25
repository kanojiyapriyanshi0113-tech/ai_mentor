package handler

import (
"net/http"
"strconv"

"github.com/gin-gonic/gin"
"github.com/google/uuid"

"ai-mentor-backend/internal/delivery/http/middleware"
"ai-mentor-backend/internal/delivery/http/response"
"ai-mentor-backend/internal/usecase"
)

type ProgressHandler struct {
progressUC usecase.ProgressUsecase
}

func NewProgressHandler(progressUC usecase.ProgressUsecase) *ProgressHandler {
return &ProgressHandler{progressUC: progressUC}
}

func (h *ProgressHandler) CompleteChapter(c *gin.Context) {
userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)
n, err := strconv.Atoi(c.Param("chapterNumber"))
if err != nil {
response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid chapterNumber")
return
}
if err := h.progressUC.CompleteChapter(c.Request.Context(), userID, n); err != nil {
response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
return
}
response.Success(c, http.StatusOK, nil, "Chapter marked complete")
}

func (h *ProgressHandler) WatchVideo(c *gin.Context) {
userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)
n, err := strconv.Atoi(c.Param("lectureNumber"))
if err != nil {
response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid lectureNumber")
return
}
if err := h.progressUC.WatchVideo(c.Request.Context(), userID, n); err != nil {
response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
return
}
response.Success(c, http.StatusOK, nil, "Video marked watched")
}

func (h *ProgressHandler) OpenNote(c *gin.Context) {
userID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)
n, err := strconv.Atoi(c.Param("noteNumber"))
if err != nil {
response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid noteNumber")
return
}
if err := h.progressUC.OpenNote(c.Request.Context(), userID, n); err != nil {
response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
return
}
response.Success(c, http.StatusOK, nil, "Note marked opened")
}

// AttemptMockTest records a mock-test submission. Quota check + increment
// already happens in middleware.RequireMockTestAccess before this runs.
func (h *ProgressHandler) AttemptMockTest(c *gin.Context) {
response.Success(c, http.StatusOK, nil, "Mock test attempt recorded")
}
