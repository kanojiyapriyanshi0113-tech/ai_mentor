package usecase

import "time"

// currentMonthKey returns the current calendar month in "2026-07" form, the
// same format used by EarningsRepository's monthKey parameter.
func currentMonthKey() string {
	return time.Now().Format("2006-01")
}

// timeNow is a thin wrapper kept so usecases can stamp entities with the
// current time without repeating time.Now() calls inline.
func timeNow() time.Time {
	return time.Now()
}
