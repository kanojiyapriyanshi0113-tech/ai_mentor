package apperror

import "errors"

var (
	// Earnings / Payouts
	ErrInvalidCommissionPercent = errors.New("commission percent must be between 0 and 100")
	ErrInvalidPayoutAmount      = errors.New("payout amount must be greater than zero")

	// Refunds
	ErrRefundNotFound          = errors.New("refund request not found")
	ErrRefundAlreadyProcessed  = errors.New("refund request has already been processed")
	ErrRefundNotApproved       = errors.New("refund request must be approved before it can be processed")
	ErrRefundInvalidAmount     = errors.New("refund amount cannot exceed the original payment amount")

	// Reports
	ErrReportNotFound = errors.New("report not found")

	// Live Classes (extended management)
	ErrLiveClassNotOwned = errors.New("this live class does not belong to you")

	// Attendance
	ErrAttendanceNotFound = errors.New("attendance record not found")

	// Assignments / Submissions
	ErrAssignmentNotOwned          = errors.New("this assignment does not belong to you")
	ErrSubmissionNotFound          = errors.New("assignment submission not found")
	ErrSubmissionAlreadyGraded     = errors.New("this submission has already been graded")
	ErrAssignmentDeadlinePassed    = errors.New("the submission deadline for this assignment has passed")

	// Notifications
	ErrUserNotificationNotFound = errors.New("notification not found")

	// Student Progress
	ErrStudentProgressNotFound = errors.New("progress record not found")

	// Certificates
	ErrCertificateNotFound         = errors.New("certificate not found")
	ErrCertificateAlreadyRevoked   = errors.New("certificate has already been revoked")

	// Generic
	ErrForbidden = errors.New("you do not have permission to perform this action")
)
