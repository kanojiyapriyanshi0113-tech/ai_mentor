package http

import (
    "github.com/gin-gonic/gin"

    "ai-mentor-backend/internal/delivery/http/handler"
    "ai-mentor-backend/internal/delivery/http/middleware"
    "ai-mentor-backend/internal/usecase"
)

type Handlers struct {
    Auth           *handler.AuthHandler
    Profile        *handler.ProfileHandler
    Exam           *handler.ExamHandler
    Reset          *handler.PasswordResetHandler
    AIChat         *handler.AIChatHandler
    ChatSession    *handler.ChatSessionHandler
    Dashboard      *handler.DashboardHandler
    Subscription   *handler.SubscriptionHandler
    Progress       *handler.ProgressHandler
    Course         *handler.CourseHandler
    CourseProgress *handler.CourseProgressHandler
    Teacher        *handler.TeacherHandler
    TeacherApplication *handler.TeacherApplicationHandler
    TeacherApplicationManage *handler.TeacherApplicationManageHandler
    TeacherApproval *handler.TeacherApprovalHandler
    StudentManagement *handler.StudentManagementHandler
    Earnings       *handler.EarningsHandler
    TeacherPayout  *handler.TeacherPayoutHandler
    Admin          *handler.AdminHandler
    StudyPlan      *handler.StudyPlanHandler
}

func RegisterRoutes(r *gin.Engine, h *Handlers, jwtSecret string, subscriptionUC usecase.SubscriptionUsecase) {
    api := r.Group("/api")
    auth := api.Group("/auth")
    {
        auth.POST("/register", h.Auth.Register)
        auth.POST("/login", h.Auth.Login)
        auth.POST("/forgot-password", h.Reset.ForgotPassword)
        auth.POST("/reset-password", h.Reset.ResetPassword)
    }
    protected := api.Group("")
    protected.Use(middleware.JWTAuth(jwtSecret))
    {
        protected.GET("/profile", h.Profile.GetProfile)
        protected.PUT("/profile", h.Profile.UpdateProfile)
        protected.GET("/exams", h.Exam.ListExams)
        protected.POST("/exams/select", h.Exam.SelectExam)
        protected.GET("/dashboard", h.Dashboard.GetDashboard)
        protected.GET("/subscription", h.Subscription.GetSubscription)
        protected.GET("/plans", h.Subscription.ListPlans)
        protected.POST("/subscription/upgrade", h.Subscription.UpgradeSubscription)
        protected.GET("/subscription/features", h.Subscription.GetFeatures)
        protected.POST("/ai/chat", middleware.RequireAIChatLimit(subscriptionUC), h.AIChat.SendMessage)
        protected.POST("/chat/session", h.ChatSession.CreateSession)
        protected.GET("/chat/sessions", h.ChatSession.ListSessions)
        protected.GET("/chat/session/:id", h.ChatSession.GetSession)
        protected.PATCH("/chat/session/:id", h.ChatSession.RenameSession)
        protected.DELETE("/chat/session/:id", h.ChatSession.DeleteSession)
        protected.POST("/chapters/:chapterNumber/complete", middleware.RequireChapterAccess(subscriptionUC), h.Progress.CompleteChapter)
        protected.POST("/videos/:lectureNumber/watch", middleware.RequireLectureAccess(subscriptionUC), h.Progress.WatchVideo)
        protected.POST("/notes/:noteNumber/open", middleware.RequireNotesAccess(subscriptionUC), h.Progress.OpenNote)
        protected.POST("/mocktest/attempt", middleware.RequireMockTestAccess(subscriptionUC), h.Progress.AttemptMockTest)
        protected.GET("/course/batches", h.Course.ListBatches)
        protected.GET("/course/batches/:id", h.Course.GetBatch)
        protected.GET("/course/subjects/:batchId", h.Course.ListSubjects)
        protected.GET("/course/chapters/:subjectId", h.Course.ListChapters)
        protected.GET("/course/lectures/:chapterId", h.Course.ListLectures)
        protected.POST("/course/lectures/:lectureId/complete", h.CourseProgress.CompleteLecture)
        protected.GET("/course/batches/:id/progress", h.CourseProgress.GetBatchProgress)

        // Become a Teacher (any authenticated student can apply)
        protected.POST("/teacher-application", h.TeacherApplication.Submit)
        protected.GET("/teacher-application/me", h.TeacherApplication.GetMine)

        // AI Planner
        protected.GET("/planner/plans", h.StudyPlan.ListPlans)
        protected.POST("/planner/plans", h.StudyPlan.CreatePlan)
        protected.PUT("/planner/plans/:id", h.StudyPlan.UpdatePlan)
        protected.DELETE("/planner/plans/:id", h.StudyPlan.DeletePlan)
        protected.POST("/planner/plans/:id/complete", h.StudyPlan.CompletePlan)
    }

    teacher := api.Group("/teacher")
    teacher.Use(middleware.JWTAuth(jwtSecret), middleware.RequireTeacher())
    {
        teacher.GET("/dashboard", h.Teacher.GetDashboard)

        teacher.POST("/batches", h.Teacher.CreateBatch)
        teacher.PUT("/batches/:id", h.Teacher.UpdateBatch)
        teacher.DELETE("/batches/:id", h.Teacher.DeleteBatch)
        teacher.PATCH("/batches/:id/publish", h.Teacher.PublishBatch)

        teacher.POST("/subjects", h.Teacher.CreateSubject)
        teacher.PUT("/subjects/:id", h.Teacher.UpdateSubject)
        teacher.DELETE("/subjects/:id", h.Teacher.DeleteSubject)

        teacher.POST("/chapters", h.Teacher.CreateChapter)
        teacher.PUT("/chapters/:id", h.Teacher.UpdateChapter)
        teacher.DELETE("/chapters/:id", h.Teacher.DeleteChapter)
        teacher.PATCH("/subjects/:subjectId/chapters/reorder", h.Teacher.ReorderChapters)

        teacher.POST("/lectures", h.Teacher.CreateLecture)
        teacher.PUT("/lectures/:id", h.Teacher.UpdateLecture)
        teacher.DELETE("/lectures/:id", h.Teacher.DeleteLecture)

        teacher.POST("/pdfs", h.Teacher.UploadPDF)
        teacher.PUT("/pdfs/:id", h.Teacher.ReplacePDF)
        teacher.DELETE("/pdfs/:id", h.Teacher.DeletePDF)
        teacher.GET("/pdfs", h.Teacher.ListPDFs)

        teacher.POST("/mocktests", h.Teacher.CreateMockTest)
        teacher.PUT("/mocktests/:id", h.Teacher.UpdateMockTest)
        teacher.DELETE("/mocktests/:id", h.Teacher.DeleteMockTest)
        teacher.GET("/mocktests", h.Teacher.ListMockTests)

        teacher.POST("/pyqs", h.Teacher.UploadPYQ)
        teacher.PUT("/pyqs/:id", h.Teacher.UpdatePYQ)
        teacher.DELETE("/pyqs/:id", h.Teacher.DeletePYQ)
        teacher.GET("/pyqs", h.Teacher.ListPYQs)

        teacher.POST("/live-classes", h.Teacher.CreateLiveClass)

        teacher.POST("/notifications", h.Teacher.SendNotification)
    }

    admin := api.Group("/admin")
    admin.Use(middleware.JWTAuth(jwtSecret), middleware.RequireAdmin())
    {
        admin.GET("/dashboard", h.Admin.GetDashboard)

        admin.POST("/teachers", h.Admin.AddTeacher)
        admin.PATCH("/teachers/:id/approve", h.Admin.ApproveTeacher)
        admin.PUT("/teachers/:id", h.Admin.EditTeacher)
        admin.PATCH("/teachers/:id/suspend", h.Admin.SuspendTeacher)
        admin.DELETE("/teachers/:id", h.Admin.DeleteTeacher)
        admin.GET("/teachers", h.Admin.ListTeachers)

        admin.GET("/teacher-applications", h.TeacherApplication.List)
        admin.GET("/teacher-applications/:id", h.TeacherApplication.Get)
        admin.PATCH("/teacher-applications/:id/approve", h.TeacherApplication.Approve)
        admin.PATCH("/teacher-applications/:id/reject", h.TeacherApplication.Reject)
        admin.PATCH("/teacher-applications/:id/request-changes", h.TeacherApplication.RequestChanges)

        RegisterTeacherApplicationManageRoutes(protected, admin, h.TeacherApplicationManage)

        RegisterTeacherApprovalRoutes(admin, h.TeacherApproval)

        RegisterStudentManagementRoutes(admin, h.StudentManagement)

        RegisterEarningsRoutes(teacher, admin, h.Earnings)
        RegisterTeacherPayoutRoutes(teacher, admin, h.TeacherPayout)

        admin.GET("/students", h.Admin.ListStudents)
        admin.PATCH("/students/:id/block", h.Admin.BlockStudent)
        admin.DELETE("/students/:id", h.Admin.DeleteStudent)

        admin.POST("/subscriptions/plans", h.Admin.CreatePlan)
        admin.PUT("/subscriptions/plans/:id", h.Admin.UpdatePlan)
        admin.PATCH("/subscriptions/plans/:id/enable", h.Admin.EnablePlan)
        admin.PATCH("/subscriptions/plans/:id/disable", h.Admin.DisablePlan)

        admin.POST("/coupons", h.Admin.CreateCoupon)
        admin.PUT("/coupons/:id", h.Admin.UpdateCoupon)
        admin.DELETE("/coupons/:id", h.Admin.DeleteCoupon)
        admin.GET("/coupons", h.Admin.ListCoupons)

        admin.GET("/payments", h.Admin.ListPayments)
        admin.POST("/payments/:id/refund", h.Admin.RefundPayment)

        admin.GET("/reports/revenue", h.Admin.GetRevenueReport)
        admin.GET("/reports/students", h.Admin.GetStudentsReport)
        admin.GET("/reports/courses", h.Admin.GetCoursesReport)

        admin.GET("/settings", h.Admin.GetSettings)
        admin.PUT("/settings/:key", h.Admin.SetSetting)

        admin.POST("/banners", h.Admin.CreateBanner)
        admin.PUT("/banners/:id", h.Admin.UpdateBanner)
        admin.DELETE("/banners/:id", h.Admin.DeleteBanner)
        admin.GET("/banners", h.Admin.ListBanners)
    }
}