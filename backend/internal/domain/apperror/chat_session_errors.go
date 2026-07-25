package apperror

import "errors"

var (
	ErrChatSessionNotFound     = errors.New("chat session not found")
	ErrInvalidChatSessionTitle = errors.New("invalid chat session title")
)