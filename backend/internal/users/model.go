package users

import "time"

type User struct {
	ID           int64
	FullName     string
	Email        string
	Phone        string
	PasswordHash string
	CreatedAt    time.Time
}

type MeResponse struct {
	ID       int64  `json:"id"`
	FullName string `json:"full_name"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
}
