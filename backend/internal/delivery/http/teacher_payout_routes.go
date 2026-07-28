package http

import (
	"github.com/gin-gonic/gin"

	"ai-mentor-backend/internal/delivery/http/handler"
)

// RegisterTeacherPayoutRoutes wires the Teacher Payout module:
//
//   - Admin Create Payout   -> POST  /admin/teachers/:id/teacher-payouts
//   - Mark Paid             -> PATCH /admin/teacher-payouts/:payoutId/mark-paid
//   - View Payouts          -> GET   /admin/teacher-payouts  (all teachers,
//     optional ?status=pending|paid and ?teacher_id= filters)
//   - Teacher Payout History -> GET  /teacher/teacher-payouts
//
// Call this once from RegisterRoutes alongside the existing teacher/admin
// route groups:
//
//	RegisterTeacherPayoutRoutes(teacher, admin, h.TeacherPayout)
func RegisterTeacherPayoutRoutes(teacher *gin.RouterGroup, admin *gin.RouterGroup, h *handler.TeacherPayoutHandler) {
	admin.POST("/teachers/:id/teacher-payouts", h.AdminCreatePayout)
	admin.PATCH("/teacher-payouts/:payoutId/mark-paid", h.AdminMarkPaid)
	admin.GET("/teacher-payouts", h.AdminListPayouts)

	teacher.GET("/teacher-payouts", h.GetMyPayoutHistory)
}
