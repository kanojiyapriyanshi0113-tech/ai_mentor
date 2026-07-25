package apperror

import "errors"

var (
    ErrSubjectNotFound   = errors.New("subject not found")
    ErrChapterNotFound   = errors.New("chapter not found")
    ErrPDFNotFound       = errors.New("pdf not found")
    ErrMockTestNotFound  = errors.New("mock test not found")
    ErrPYQNotFound       = errors.New("pyq not found")
    ErrLiveClassNotFound = errors.New("live class not found")
)
