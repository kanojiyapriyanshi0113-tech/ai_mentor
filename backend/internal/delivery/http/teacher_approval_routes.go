package http

import (
	"github.com/gin-gonic/gin"

	"ai-mentor-backend/internal/delivery/http/handler"
)

// RegisterTeacherApprovalRoutes wires the Teacher Approval module:
//
//   - Pending Applications -> GET   /admin/teacher-approvals/pending
//     (?limit=&offset=, defaults 20/0)
//   - Approve               -> PATCH /admin/teacher-approvals/:id/approve
//   - Reject                -> PATCH /admin/teacher-approvals/:id/reject
//   - Suspend Teacher       -> PATCH /admin/teacher-approvals/teachers/:id/suspend
//     (body: {"suspend": true|false})
//
// All routes sit under the existing admin group, which already applies
// middleware.JWTAuth + middleware.RequireAdmin (existing JWT + RBAC), so no
// extra middleware is added here. Call this once from RegisterRoutes
// alongside the other admin sub-modules, and add TeacherApproval
// *handler.TeacherApprovalHandler to the Handlers struct:
//
//	RegisterTeacherApprovalRoutes(admin, h.TeacherApproval)
func RegisterTeacherApprovalRoutes(admin *gin.RouterGroup, h *handler.TeacherApprovalHandler) {
	admin.GET("/teacher-approvals/pending", h.PendingApplications)
	admin.PATCH("/teacher-approvals/:id/approve", h.Approve)
	admin.PATCH("/teacher-approvals/:id/reject", h.Reject)
	admin.PATCH("/teacher-approvals/teachers/:id/suspend", h.SuspendTeacher)
}
