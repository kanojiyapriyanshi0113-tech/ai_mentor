package entity

import (
	"time"

	"github.com/google/uuid"
)

// CertificateStatus is the validity state of an issued certificate.
type CertificateStatus string

const (
	CertificateIssued  CertificateStatus = "issued"
	CertificateRevoked CertificateStatus = "revoked"
)

// Certificate is a completion/achievement certificate issued to a student.
type Certificate struct {
	ID                uuid.UUID
	StudentID         uuid.UUID
	BatchID           *uuid.UUID
	CertificateNumber string
	Title             string
	FileURL           string
	Status            CertificateStatus
	IssuedBy          *uuid.UUID
	IssuedAt          time.Time
	RevokedAt         *time.Time
	CreatedAt         time.Time
	UpdatedAt         time.Time
	DeletedAt         *time.Time
}
