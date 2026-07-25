package apperror

import "errors"

var (
    ErrEmailAlreadyExists = errors.New("email already registered")
    ErrInvalidCredentials = errors.New("invalid email or password")
    ErrUserNotFound       = errors.New("user not found")
    ErrExamNotFound       = errors.New("exam not found")
    ErrInvalidInput       = errors.New("invalid input")
    ErrTokenInvalid       = errors.New("invalid or expired token")
    ErrTokenUsed          = errors.New("token already used")
    ErrAIProviderFailed   = errors.New("ai provider request failed")
    ErrInternal           = errors.New("internal server error")
    ErrPlanNotFound       = errors.New("plan not found")
    ErrFeatureLimitExceeded = errors.New("feature limit exceeded")
)

