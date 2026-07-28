package handler

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

// paginationParams is the common (limit, offset) pair accepted by every
// paginated list endpoint added across the new modules.
type paginationParams struct {
	Limit  int
	Offset int
}

// parsePagination reads ?limit=&offset= from the query string, applying
// sane defaults and bounds so callers can't request unbounded result sets.
func parsePagination(c *gin.Context) paginationParams {
	limit, err := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if err != nil || limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	offset, err := strconv.Atoi(c.DefaultQuery("offset", "0"))
	if err != nil || offset < 0 {
		offset = 0
	}
	return paginationParams{Limit: limit, Offset: offset}
}
