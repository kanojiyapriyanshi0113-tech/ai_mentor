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

type TeacherHandler struct {
    teacherUC usecase.TeacherUsecase
}

func NewTeacherHandler(teacherUC usecase.TeacherUsecase) *TeacherHandler {
    return &TeacherHandler{teacherUC: teacherUC}
}

func toLiveClassDTO(l entity.LiveClass) dto.LiveClassResponse {
    return dto.LiveClassResponse{
        ID:          l.ID,
        BatchID:     l.BatchID,
        Title:       l.Title,
        ScheduledAt: l.ScheduledAt,
        MeetingURL:  l.MeetingURL,
    }
}

func toPDFDTO(p entity.PDF) dto.PDFResponse {
    return dto.PDFResponse{
        ID:           p.ID,
        ChapterID:    p.ChapterID,
        Title:        p.Title,
        FileURL:      p.FileURL,
        DisplayOrder: p.DisplayOrder,
    }
}

func toMockTestDTO(m entity.MockTest) dto.MockTestResponse {
    return dto.MockTestResponse{
        ID:              m.ID,
        BatchID:         m.BatchID,
        Title:           m.Title,
        DurationMinutes: m.DurationMinutes,
        TotalQuestions:  m.TotalQuestions,
    }
}

func toPYQDTO(p entity.PYQ) dto.PYQResponse {
    return dto.PYQResponse{
        ID:         p.ID,
        BatchID:    p.BatchID,
        ExamName:   p.ExamName,
        Year:       p.Year,
        SubjectTag: p.SubjectTag,
        FileURL:    p.FileURL,
    }
}

func handleTeacherError(c *gin.Context, err error) {
    switch {
    case errors.Is(err, apperror.ErrBatchNotFound):
        response.Error(c, http.StatusNotFound, "BATCH_NOT_FOUND", "Batch not found")
    case errors.Is(err, apperror.ErrSubjectNotFound):
        response.Error(c, http.StatusNotFound, "SUBJECT_NOT_FOUND", "Subject not found")
    case errors.Is(err, apperror.ErrChapterNotFound):
        response.Error(c, http.StatusNotFound, "CHAPTER_NOT_FOUND", "Chapter not found")
    case errors.Is(err, apperror.ErrLectureNotFound):
        response.Error(c, http.StatusNotFound, "LECTURE_NOT_FOUND", "Lecture not found")
    case errors.Is(err, apperror.ErrPDFNotFound):
        response.Error(c, http.StatusNotFound, "PDF_NOT_FOUND", "PDF not found")
    case errors.Is(err, apperror.ErrMockTestNotFound):
        response.Error(c, http.StatusNotFound, "MOCK_TEST_NOT_FOUND", "Mock test not found")
    case errors.Is(err, apperror.ErrPYQNotFound):
        response.Error(c, http.StatusNotFound, "PYQ_NOT_FOUND", "PYQ not found")
    default:
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
    }
}

func (h *TeacherHandler) GetDashboard(c *gin.Context) {
    stats, err := h.teacherUC.GetDashboard(c.Request.Context())
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    liveClasses := make([]dto.LiveClassResponse, 0, len(stats.UpcomingLiveClasses))
    for _, lc := range stats.UpcomingLiveClasses {
        liveClasses = append(liveClasses, toLiveClassDTO(lc))
    }
    response.Success(c, http.StatusOK, dto.TeacherDashboardResponse{
        TotalStudents:       stats.TotalStudents,
        TotalBatches:        stats.TotalBatches,
        TotalSubjects:       stats.TotalSubjects,
        TotalChapters:       stats.TotalChapters,
        TotalLectures:       stats.TotalLectures,
        TotalPDFs:           stats.TotalPDFs,
        TotalMockTests:      stats.TotalMockTests,
        UpcomingLiveClasses: liveClasses,
    }, "")
}

func (h *TeacherHandler) CreateBatch(c *gin.Context) {
    var req dto.CreateBatchRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    batch, err := h.teacherUC.CreateBatch(c.Request.Context(), usecase.CreateBatchInput{
        ExamID:      req.ExamID,
        Title:       req.Title,
        Description: req.Description,
        Thumbnail:   req.Thumbnail,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toBatchDTO(*batch), "Batch created")
}

func (h *TeacherHandler) UpdateBatch(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid batch id")
        return
    }
    var req dto.UpdateBatchRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.UpdateBatch(c.Request.Context(), usecase.UpdateBatchInput{
        ID:          id,
        Title:       req.Title,
        Description: req.Description,
        Thumbnail:   req.Thumbnail,
        IsActive:    req.IsActive,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Batch updated")
}

func (h *TeacherHandler) DeleteBatch(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid batch id")
        return
    }
    if err := h.teacherUC.DeleteBatch(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Batch deleted")
}

func (h *TeacherHandler) PublishBatch(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid batch id")
        return
    }
    var req dto.PublishBatchRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.teacherUC.PublishBatch(c.Request.Context(), id, req.Publish); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Batch publish status updated")
}

func (h *TeacherHandler) CreateSubject(c *gin.Context) {
    var req dto.CreateSubjectRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    subject, err := h.teacherUC.CreateSubject(c.Request.Context(), usecase.CreateSubjectInput{
        BatchID:      req.BatchID,
        Name:         req.Name,
        Icon:         req.Icon,
        DisplayOrder: req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toSubjectDTO(*subject), "Subject created")
}

func (h *TeacherHandler) UpdateSubject(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid subject id")
        return
    }
    var req dto.UpdateSubjectRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.UpdateSubject(c.Request.Context(), usecase.UpdateSubjectInput{
        ID:           id,
        Name:         req.Name,
        Icon:         req.Icon,
        DisplayOrder: req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Subject updated")
}

func (h *TeacherHandler) DeleteSubject(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid subject id")
        return
    }
    if err := h.teacherUC.DeleteSubject(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Subject deleted")
}

func (h *TeacherHandler) CreateChapter(c *gin.Context) {
    var req dto.CreateChapterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    chapter, err := h.teacherUC.CreateChapter(c.Request.Context(), usecase.CreateChapterInput{
        SubjectID:    req.SubjectID,
        Title:        req.Title,
        Description:  req.Description,
        DisplayOrder: req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toChapterDTO(*chapter), "Chapter created")
}

func (h *TeacherHandler) UpdateChapter(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid chapter id")
        return
    }
    var req dto.UpdateChapterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.UpdateChapter(c.Request.Context(), usecase.UpdateChapterInput{
        ID:           id,
        Title:        req.Title,
        Description:  req.Description,
        DisplayOrder: req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Chapter updated")
}

func (h *TeacherHandler) DeleteChapter(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid chapter id")
        return
    }
    if err := h.teacherUC.DeleteChapter(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Chapter deleted")
}

func (h *TeacherHandler) ReorderChapters(c *gin.Context) {
    subjectID := c.Param("subjectId")
    if _, err := uuid.Parse(subjectID); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid subject id")
        return
    }
    var req dto.ReorderChaptersRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.teacherUC.ReorderChapters(c.Request.Context(), subjectID, req.OrderedIDs); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Failed to reorder chapters")
        return
    }
    response.Success(c, http.StatusOK, nil, "Chapters reordered")
}

func (h *TeacherHandler) CreateLecture(c *gin.Context) {
    var req dto.CreateLectureRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    lecture, err := h.teacherUC.CreateLecture(c.Request.Context(), usecase.CreateLectureInput{
        ChapterID:       req.ChapterID,
        Title:           req.Title,
        Description:     req.Description,
        DurationMinutes: req.DurationMinutes,
        VideoURL:        req.VideoURL,
        IsPreview:       req.IsPreview,
        DisplayOrder:    req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toLectureDTO(*lecture), "Lecture uploaded")
}

func (h *TeacherHandler) UpdateLecture(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid lecture id")
        return
    }
    var req dto.UpdateLectureRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.UpdateLecture(c.Request.Context(), usecase.UpdateLectureInput{
        ID:              id,
        Title:           req.Title,
        Description:     req.Description,
        DurationMinutes: req.DurationMinutes,
        VideoURL:        req.VideoURL,
        IsPreview:       req.IsPreview,
        DisplayOrder:    req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Lecture updated")
}

func (h *TeacherHandler) DeleteLecture(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid lecture id")
        return
    }
    if err := h.teacherUC.DeleteLecture(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Lecture deleted")
}

func (h *TeacherHandler) UploadPDF(c *gin.Context) {
    var req dto.UploadPDFRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    pdf, err := h.teacherUC.UploadPDF(c.Request.Context(), usecase.CreatePDFInput{
        ChapterID:    req.ChapterID,
        Title:        req.Title,
        FileURL:      req.FileURL,
        DisplayOrder: req.DisplayOrder,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toPDFDTO(*pdf), "PDF uploaded")
}

func (h *TeacherHandler) ReplacePDF(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid pdf id")
        return
    }
    var req dto.ReplacePDFRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    if err := h.teacherUC.ReplacePDF(c.Request.Context(), id, req.FileURL); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "PDF replaced")
}

func (h *TeacherHandler) DeletePDF(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid pdf id")
        return
    }
    if err := h.teacherUC.DeletePDF(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "PDF deleted")
}

func (h *TeacherHandler) CreateMockTest(c *gin.Context) {
    var req dto.CreateMockTestRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    mockTest, err := h.teacherUC.CreateMockTest(c.Request.Context(), usecase.CreateMockTestInput{
        BatchID:         req.BatchID,
        Title:           req.Title,
        DurationMinutes: req.DurationMinutes,
        TotalQuestions:  req.TotalQuestions,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toMockTestDTO(*mockTest), "Mock test created")
}

func (h *TeacherHandler) UpdateMockTest(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid mock test id")
        return
    }
    var req dto.UpdateMockTestRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.UpdateMockTest(c.Request.Context(), usecase.UpdateMockTestInput{
        ID:              id,
        Title:           req.Title,
        DurationMinutes: req.DurationMinutes,
        TotalQuestions:  req.TotalQuestions,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Mock test updated")
}

func (h *TeacherHandler) DeleteMockTest(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid mock test id")
        return
    }
    if err := h.teacherUC.DeleteMockTest(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Mock test deleted")
}

func (h *TeacherHandler) UploadPYQ(c *gin.Context) {
    var req dto.UploadPYQRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    pyq, err := h.teacherUC.UploadPYQ(c.Request.Context(), usecase.CreatePYQInput{
        BatchID:    req.BatchID,
        ExamName:   req.ExamName,
        Year:       req.Year,
        SubjectTag: req.SubjectTag,
        FileURL:    req.FileURL,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toPYQDTO(*pyq), "PYQ uploaded")
}

func (h *TeacherHandler) UpdatePYQ(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid pyq id")
        return
    }
    var req dto.UpdatePYQRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.UpdatePYQ(c.Request.Context(), usecase.UpdatePYQInput{
        ID:         id,
        ExamName:   req.ExamName,
        Year:       req.Year,
        SubjectTag: req.SubjectTag,
        FileURL:    req.FileURL,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "PYQ updated")
}

func (h *TeacherHandler) DeletePYQ(c *gin.Context) {
    id := c.Param("id")
    if _, err := uuid.Parse(id); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid pyq id")
        return
    }
    if err := h.teacherUC.DeletePYQ(c.Request.Context(), id); err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "PYQ deleted")
}

func (h *TeacherHandler) CreateLiveClass(c *gin.Context) {
    var req dto.CreateLiveClassRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    liveClass, err := h.teacherUC.CreateLiveClass(c.Request.Context(), usecase.CreateLiveClassInput{
        BatchID:     req.BatchID,
        Title:       req.Title,
        ScheduledAt: req.ScheduledAt,
        MeetingURL:  req.MeetingURL,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusCreated, toLiveClassDTO(*liveClass), "Live class scheduled")
}

func (h *TeacherHandler) SendNotification(c *gin.Context) {
    senderID := c.MustGet(middleware.ContextUserIDKey).(uuid.UUID)

    var req dto.SendNotificationRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid request body")
        return
    }
    err := h.teacherUC.SendNotification(c.Request.Context(), usecase.SendNotificationInput{
        BatchID:  req.BatchID,
        SenderID: senderID.String(),
        Title:    req.Title,
        Message:  req.Message,
    })
    if err != nil {
        handleTeacherError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Notification sent")
}
