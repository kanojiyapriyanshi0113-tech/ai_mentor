package middleware

import (
    "errors"
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"

    "ai-mentor-backend/internal/delivery/http/response"
    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/usecase"
)

func writeUpgradeRequired(c *gin.Context) {
    c.JSON(http.StatusForbidden, gin.H{"message": "Upgrade your plan to continue."})
    c.Abort()
}

// RequireAIChatLimit enforces the plan''s daily AI-chat quota. Attach to POST /api/ai/chat.
func RequireAIChatLimit(subscriptionUC usecase.SubscriptionUsecase) gin.HandlerFunc {
    return func(c *gin.Context) {
        userID := c.MustGet(ContextUserIDKey).(uuid.UUID)
        if err := subscriptionUC.CheckDailyLimit(c.Request.Context(), userID, "ai_chat_daily_limit"); err != nil {
            if errors.Is(err, apperror.ErrFeatureLimitExceeded) {
                writeUpgradeRequired(c)
                return
            }
            response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
            c.Abort()
            return
        }
        c.Next()
    }
}

// RequireMockTestAccess enforces the plan''s lifetime mock-test quota.
// Attach to whichever route starts a mock-test attempt once that feature exists.
func RequireMockTestAccess(subscriptionUC usecase.SubscriptionUsecase) gin.HandlerFunc {
    return func(c *gin.Context) {
        userID := c.MustGet(ContextUserIDKey).(uuid.UUID)
        if err := subscriptionUC.CheckLifetimeLimit(c.Request.Context(), userID, "max_mock_tests"); err != nil {
            if errors.Is(err, apperror.ErrFeatureLimitExceeded) {
                writeUpgradeRequired(c)
                return
            }
            response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
            c.Abort()
            return
        }
        c.Next()
    }
}

// requireOrdinalAccess backs chapter/lecture/notes checks: the resource''s
// 1-based position must be within the plan''s limit. Reads ordinal from a URL param.
func requireOrdinalAccess(subscriptionUC usecase.SubscriptionUsecase, featureKey, paramName string) gin.HandlerFunc {
    return func(c *gin.Context) {
        userID := c.MustGet(ContextUserIDKey).(uuid.UUID)

        ordinal, err := strconv.Atoi(c.Param(paramName))
        if err != nil {
            response.Error(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid "+paramName)
            c.Abort()
            return
        }

        if err := subscriptionUC.CheckOrdinalLimit(c.Request.Context(), userID, featureKey, ordinal); err != nil {
            if errors.Is(err, apperror.ErrFeatureLimitExceeded) {
                writeUpgradeRequired(c)
                return
            }
            response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong")
            c.Abort()
            return
        }
        c.Next()
    }
}

// RequireChapterAccess: attach to a route with a :chapterNumber param.
func RequireChapterAccess(subscriptionUC usecase.SubscriptionUsecase) gin.HandlerFunc {
    return requireOrdinalAccess(subscriptionUC, "max_chapters", "chapterNumber")
}

// RequireLectureAccess: attach to a route with a :lectureNumber param.
func RequireLectureAccess(subscriptionUC usecase.SubscriptionUsecase) gin.HandlerFunc {
    return requireOrdinalAccess(subscriptionUC, "max_lectures", "lectureNumber")
}

// RequireNotesAccess: attach to a route with a :noteNumber param.
func RequireNotesAccess(subscriptionUC usecase.SubscriptionUsecase) gin.HandlerFunc {
    return requireOrdinalAccess(subscriptionUC, "max_notes", "noteNumber")
}