package entity

// Role represents a user's access level within the platform.
type Role string

const (
    RoleAdmin   Role = "admin"
    RoleTeacher Role = "teacher"
    RoleStudent Role = "student"
)

// IsValid reports whether r is one of the known roles.
func (r Role) IsValid() bool {
    switch r {
    case RoleAdmin, RoleTeacher, RoleStudent:
        return true
    default:
        return false
    }
}

// String returns the string form of the role.
func (r Role) String() string {
    return string(r)
}
