package apperror

import "errors"

// Teacher Payout module. Reuses ErrInvalidInput and ErrInvalidPayoutAmount
// (defined for the Earnings module) for input validation.
var (
	ErrPayoutNotFound    = errors.New("payout record not found")
	ErrPayoutAlreadyPaid = errors.New("payout has already been marked as paid")
)
