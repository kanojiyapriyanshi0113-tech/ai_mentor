package apperror

import "errors"

var (
    ErrTeacherNotFound        = errors.New("teacher not found")
    ErrStudentNotFound        = errors.New("student not found")
    ErrCouponNotFound         = errors.New("coupon not found")
    ErrCouponCodeExists       = errors.New("coupon code already exists")
    ErrPaymentNotFound        = errors.New("payment not found")
    ErrPaymentAlreadyRefunded = errors.New("payment already refunded")
    ErrBannerNotFound         = errors.New("banner not found")
)
