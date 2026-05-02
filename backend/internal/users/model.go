package users

import "time"

type User struct {
	ID           int64
	FullName     string
	Email        string
	Phone        string
	Role         string
	Status       string
	PasswordHash string
	CreatedAt    time.Time
	UpdatedAt    time.Time
	SuspendedAt  *time.Time
}

type MeResponse struct {
	ID       int64  `json:"id"`
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Role     string `json:"role"`
	Status   string `json:"status"`
}
