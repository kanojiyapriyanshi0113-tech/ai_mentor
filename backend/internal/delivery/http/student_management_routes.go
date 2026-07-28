package http

import (
    "github.com/gin-gonic/gin"

    "ai-mentor-backend/internal/delivery/http/handler"
)

// RegisterStudentManagementRoutes wires the Student Management module:
//
//   - List Students -> GET    /admin/student-management
//     (?search=&limit=&offset=, defaults 20/0)
//   - View Student  -> GET    /admin/student-management/:id
//   - Block         -> PATCH  /admin/student-management/:id/block
//   - Unblock       -> PATCH  /admin/student-management/:id/unblock
//   - Delete        -> DELETE /admin/student-management/:id
//
// Paths are distinct from the existing /admin/students* routes so both can
// coexist. All routes sit under the existing admin group, which already
// applies middleware.JWTAuth + middleware.RequireAdmin (existing JWT +
// RBAC), so no extra middleware is added here. Call this once from
// RegisterRoutes alongside the other admin sub-modules, and add
// StudentManagement *handler.StudentManagementHandler to the Handlers
// struct:
//
//    RegisterStudentManagementRoutes(admin, h.StudentManagement)
func RegisterStudentManagementRoutes(admin *gin.RouterGroup, h *handler.StudentManagementHandler) {
    admin.GET("/student-management", h.ListStudents)
    admin.GET("/student-management/:id", h.GetStudent)
    admin.PATCH("/student-management/:id/block", h.Block)
    admin.PATCH("/student-management/:id/unblock", h.Unblock)
    admin.DELETE("/student-management/:id", h.Delete)
}
