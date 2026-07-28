package apperror

import "errors"

var (
	ErrTeacherApplicationNotFound   = errors.New("teacher application not found")
	ErrTeacherApplicationOpenExists = errors.New("you already have an application under review")
	ErrTeacherApplicationNotEditable = errors.New("this application has already been reviewed")
	ErrAssignmentNotFound           = errors.New("assignment not found")
)