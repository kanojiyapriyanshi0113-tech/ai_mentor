package http

import (
	"github.com/gin-gonic/gin"

	"ai-mentor-backend/internal/delivery/http/handler"
)

// RegisterEarningsRoutes wires the teacher earnings & payouts module:
//
//   - Earnings Summary   -> GET /teacher/earnings            (also carries
//     Monthly Earnings and Pending Payout as fields on the same response,
//     so a teacher gets all three in one call)
//   - Payout History     -> GET /teacher/earnings/payouts
//   - My Students         -> GET /teacher/earnings/students
//
// Plus the admin side that manages commission rate and records payouts:
//
//   - GET   /admin/teachers/:id/earnings
//   - GET   /admin/teachers/:id/payouts
//   - PATCH /admin/teachers/:id/commission
//   - POST  /admin/teachers/:id/payouts
//
// Call this once from RegisterRoutes alongside the existing teacher/admin
// route groups:
//
//	RegisterEarningsRoutes(teacher, admin, h.Earnings)
func RegisterEarningsRoutes(teacher *gin.RouterGroup, admin *gin.RouterGroup, h *handler.EarningsHandler) {
	teacher.GET("/earnings", h.GetMySummary)
	teacher.GET("/earnings/payouts", h.GetMyPayouts)
	teacher.GET("/earnings/students", h.GetMyStudents)

	admin.GET("/teachers/:id/earnings", h.GetTeacherSummary)
	admin.GET("/teachers/:id/payouts", h.ListTeacherPayouts)
	admin.PATCH("/teachers/:id/commission", h.SetCommission)
	admin.POST("/teachers/:id/payouts", h.CreatePayout)
}
