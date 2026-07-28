package handler

import (
    "errors"
    "net/http"

    "github.com/gin-gonic/gin"

    "ai-mentor-backend/internal/delivery/http/dto"
    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/usecase"
)

// StudentManagementHandler exposes the admin Student Management screen:
// list (search + pagination), view, block, unblock, delete. It reuses the
// StudentAccountResponse DTO and toStudentDTO mapper already defined
// alongside AdminHandler.
type StudentManagementHandler struct {
    uc usecase.StudentManagementUsecase
}

func NewStudentManagementHandler(uc usecase.StudentManagementUsecase) *StudentManagementHandler {
    return &StudentManagementHandler{uc: uc}
}

func handleStudentManagementError(c *gin.Context, err error) {
    switch {
    case errors.Is(err, apperror.ErrStudentNotFound):
        response.Error(c, http.StatusNotFound, "NOT_FOUND", err.Error())
    case errors.Is(err, apperror.ErrInvalidInput):
        response.Error(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
    default:
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
    }
}

// ListStudents handles GET /admin/student-management?search=&limit=&offset=.
func (h *StudentManagementHandler) ListStudents(c *gin.Context) {
    search := c.Query("search")
    p := parsePagination(c)

    students, total, err := h.uc.ListStudents(c.Request.Context(), search, p.Limit, p.Offset)
    if err != nil {
        handleStudentManagementError(c, err)
        return
    }
    out := make([]dto.StudentAccountResponse, 0, len(students))
    for _, s := range students {
        out = append(out, toStudentDTO(s))
    }
    response.Success(c, http.StatusOK, dto.PagedResponse{
        Items: out,
        Meta:  dto.PageMeta{Total: total, Limit: p.Limit, Offset: p.Offset},
    }, "")
}

// GetStudent handles GET /admin/student-management/:id.
func (h *StudentManagementHandler) GetStudent(c *gin.Context) {
    student, err := h.uc.GetStudent(c.Request.Context(), c.Param("id"))
    if err != nil {
        handleStudentManagementError(c, err)
        return
    }
    response.Success(c, http.StatusOK, toStudentDTO(*student), "")
}

// Block handles PATCH /admin/student-management/:id/block.
func (h *StudentManagementHandler) Block(c *gin.Context) {
    if err := h.uc.Block(c.Request.Context(), c.Param("id")); err != nil {
        handleStudentManagementError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Student blocked")
}

// Unblock handles PATCH /admin/student-management/:id/unblock.
func (h *StudentManagementHandler) Unblock(c *gin.Context) {
    if err := h.uc.Unblock(c.Request.Context(), c.Param("id")); err != nil {
        handleStudentManagementError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Student unblocked")
}

// Delete handles DELETE /admin/student-management/:id.
func (h *StudentManagementHandler) Delete(c *gin.Context) {
    if err := h.uc.Delete(c.Request.Context(), c.Param("id")); err != nil {
        handleStudentManagementError(c, err)
        return
    }
    response.Success(c, http.StatusOK, nil, "Student deleted")
}
