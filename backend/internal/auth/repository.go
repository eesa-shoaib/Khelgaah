package auth

import (
	"context"
	"errors"

	"github.com/eesa/khelgaah/backend/internal/users"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type CreateUserParams struct {
	FullName     string
	Email        string
	PasswordHash string
	Phone        string
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) CreateUser(ctx context.Context, params CreateUserParams) (users.User, error) {
	query := `
		INSERT INTO users (full_name, email, password_hash, phone)
		VALUES ($1, $2, $3, $4)
		RETURNING id, full_name, email, phone, password_hash, created_at
	`

	var user users.User
	err := r.db.QueryRow(ctx, query, params.FullName, params.Email, params.PasswordHash, params.Phone).
		Scan(&user.ID, &user.FullName, &user.Email, &user.Phone, &user.PasswordHash, &user.CreatedAt)
	return user, err
}

func (r *repository) FindByEmail(ctx context.Context, email string) (users.User, error) {
	query := `
		SELECT id, full_name, email, phone, password_hash, created_at
		FROM users
		WHERE email = $1
	`

	var user users.User
	err := r.db.QueryRow(ctx, query, email).
		Scan(&user.ID, &user.FullName, &user.Email, &user.Phone, &user.PasswordHash, &user.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return users.User{}, ErrInvalidCredentials
	}
	return user, err
}
