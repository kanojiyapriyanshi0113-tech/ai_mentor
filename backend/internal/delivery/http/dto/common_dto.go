package dto

// PageMeta describes pagination state for a list response.
type PageMeta struct {
	Total  int `json:"total"`
	Limit  int `json:"limit"`
	Offset int `json:"offset"`
}

// PagedResponse wraps a list of items with pagination metadata. Used by the
// newer list endpoints (earnings, refunds, reports, live classes,
// assignments, notifications, certificates, attendance, progress) that need
// to report total counts alongside the current page.
type PagedResponse struct {
	Items interface{} `json:"items"`
	Meta  PageMeta    `json:"meta"`
}
