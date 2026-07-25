# Run this from: C:\Users\ABC\Desktop\AI_Mentor\backend
# Usage:  .\fix_cors.ps1

$ErrorActionPreference = "Stop"

Write-Host "Installing gin-contrib/cors..."
go get github.com/gin-contrib/cors

$mainGoContent = @'
package main

import (
    "context"
    "log"
    "strings"

    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/config"
    httpDelivery "ai-mentor-backend/internal/delivery/http"
    "ai-mentor-backend/internal/delivery/http/handler"
    "ai-mentor-backend/internal/infra/ai"
    "ai-mentor-backend/internal/repository/postgres"
    "ai-mentor-backend/internal/usecase"
)

func main() {
    cfg := config.Load()
    if cfg.DatabaseURL == "" {
        log.Fatal("DATABASE_URL environment variable is required")
    }

    pool, err := pgxpool.New(context.Background(), cfg.DatabaseURL)
    if err != nil {
        log.Fatalf("failed to connect to database: %v", err)
    }
    defer pool.Close()

    if err := pool.Ping(context.Background()); err != nil {
        log.Fatalf("failed to ping database: %v", err)
    }

    // Repositories
    userRepo := postgres.NewUserRepository(pool)
    examRepo := postgres.NewExamRepository(pool)
    resetRepo := postgres.NewPasswordResetRepository(pool)
    aiChatRepo := postgres.NewAIChatRepository(pool)
    planRepo := postgres.NewPlanRepository(pool)
    subRepo := postgres.NewSubscriptionRepository(pool)
    featureRepo := postgres.NewSubscriptionFeatureRepository(pool)
    usageRepo := postgres.NewUserUsageRepository(pool)
    progressRepo := postgres.NewUserProgressRepository(pool)
    chatSessionRepo := postgres.NewChatSessionRepository(pool)
    courseRepo := postgres.NewCourseRepository(pool)
    courseProgressRepo := postgres.NewCourseProgressRepository(pool)

    // External providers
    aiProvider := ai.NewGroqProvider(cfg.GroqAPIKey, cfg.GroqModel)

    // Usecases
    authUC := usecase.NewAuthUsecase(userRepo, cfg.JWTSecret)
    profileUC := usecase.NewProfileUsecase(userRepo)
    examUC := usecase.NewExamUsecase(examRepo)
    resetUC := usecase.NewPasswordResetUsecase(userRepo, resetRepo)
    dashboardUC := usecase.NewDashboardUsecase(userRepo, examRepo)
    subscriptionUC := usecase.NewSubscriptionUsecase(subRepo, planRepo, featureRepo, usageRepo, userRepo, progressRepo)
    progressUC := usecase.NewProgressUsecase(progressRepo)
    aiChatUC := usecase.NewAIChatUsecase(aiChatRepo, chatSessionRepo, aiProvider, subscriptionUC)
    chatSessionUC := usecase.NewChatSessionUsecase(chatSessionRepo, aiChatRepo)
    courseUC := usecase.NewCourseUsecase(courseRepo, examRepo)
    courseProgressUC := usecase.NewCourseProgressUsecase(courseProgressRepo)

    // Handlers
    h := &httpDelivery.Handlers{
        Auth:           handler.NewAuthHandler(authUC),
        Profile:        handler.NewProfileHandler(profileUC),
        Exam:           handler.NewExamHandler(examUC),
        Reset:          handler.NewPasswordResetHandler(resetUC),
        AIChat:         handler.NewAIChatHandler(aiChatUC),
        ChatSession:    handler.NewChatSessionHandler(chatSessionUC),
        Dashboard:      handler.NewDashboardHandler(dashboardUC),
        Subscription:   handler.NewSubscriptionHandler(subscriptionUC),
        Progress:       handler.NewProgressHandler(progressUC),
        Course:         handler.NewCourseHandler(courseUC),
        CourseProgress: handler.NewCourseProgressHandler(courseProgressUC),
    }

    r := gin.Default()

    // CORS - allows the Flutter web dev server (random localhost port each run)
    // to call this API. Tighten AllowOriginFunc before shipping to production.
    r.Use(cors.New(cors.Config{
        AllowOriginFunc: func(origin string) bool {
            return strings.HasPrefix(origin, "http://localhost:") ||
                strings.HasPrefix(origin, "http://127.0.0.1:")
        },
        AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
        AllowCredentials: true,
    }))

    httpDelivery.RegisterRoutes(r, h, cfg.JWTSecret, subscriptionUC)

    log.Printf("server starting on port %s", cfg.Port)
    if err := r.Run(":" + cfg.Port); err != nil {
        log.Fatalf("server failed: %v", err)
    }
}
'@
[System.IO.File]::WriteAllText("$PWD\cmd\server\main.go", $mainGoContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Wrote main.go"

Write-Host ""
Write-Host "Verifying..."
Select-String -Path "cmd\server\main.go" -Pattern "cors.New"

Write-Host ""
Write-Host "Building to confirm it compiles..."
go build ./...
Write-Host "Build result: $LASTEXITCODE (0 = success)"

Write-Host ""
Write-Host "Now restart the backend server (go run cmd\server\main.go) and re-test login in Chrome."
