package users

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	FindByID(ctx context.Context, id int64) (User, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) FindByID(ctx context.Context, id int64) (User, error) {
	query := `
		SELECT id, full_name, email, phone, role, status, password_hash, created_at, updated_at, suspended_at
		FROM users
		WHERE id = $1
	`

	var user User
	err := r.db.QueryRow(ctx, query, id).
		Scan(
			&user.ID,
			&user.FullName,
			&user.Email,
			&user.Phone,
			&user.Role,
			&user.Status,
			&user.PasswordHash,
			&user.CreatedAt,
			&user.UpdatedAt,
			&user.SuspendedAt,
		)
	return user, err
}
