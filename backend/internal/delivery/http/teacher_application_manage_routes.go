package http

import (
	"github.com/gin-gonic/gin"

	"ai-mentor-backend/internal/delivery/http/handler"
)

// RegisterTeacherApplicationManageRoutes wires the applicant-editable and
// admin-search endpoints that extend the existing Become-a-Teacher
// application routes (submit/view/approve/reject already registered in
// routes.go). Call this once from RegisterRoutes alongside the existing
// teacher-application routes:
//
//	RegisterTeacherApplicationManageRoutes(protected, admin, h.TeacherApplicationManage)
func RegisterTeacherApplicationManageRoutes(protected *gin.RouterGroup, admin *gin.RouterGroup, h *handler.TeacherApplicationManageHandler) {
	protected.PUT("/teacher-application/me", h.Update)
	protected.DELETE("/teacher-application/me", h.Cancel)

	admin.GET("/teacher-applications/search", h.SearchList)
}
