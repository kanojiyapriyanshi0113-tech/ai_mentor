package usecase

import "github.com/google/uuid"

func uuidParse(s string) (uuid.UUID, error) {
    return uuid.Parse(s)
}
