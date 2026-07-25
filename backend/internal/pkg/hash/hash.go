package hash

import "golang.org/x/crypto/bcrypt"

const bcryptCost = 12

// HashPassword returns a bcrypt hash of the plaintext password.
func HashPassword(plain string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(plain), bcryptCost)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

// ComparePassword reports whether plain matches the given bcrypt hash.
func ComparePassword(hashVal, plain string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hashVal), []byte(plain)) == nil
}
