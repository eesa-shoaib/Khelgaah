package bookings

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	Create(ctx context.Context, tx pgx.Tx, userID, facilityID int64, start, end time.Time) (Booking, error)
	ListByUser(ctx context.Context, userID int64) ([]Booking, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) Create(ctx context.Context, tx pgx.Tx, userID, facilityID int64, start, end time.Time) (Booking, error) {
	query := `
		INSERT INTO bookings (user_id, facility_id, start_time, end_time, status)
		VALUES ($1, $2, $3, $4, 'confirmed')
		RETURNING id, user_id, facility_id, start_time, end_time, status, created_at
	`

	var booking Booking
	err := tx.QueryRow(ctx, query, userID, facilityID, start, end).
		Scan(&booking.ID, &booking.UserID, &booking.FacilityID, &booking.StartTime, &booking.EndTime, &booking.Status, &booking.CreatedAt)
	return booking, err
}

func (r *repository) ListByUser(ctx context.Context, userID int64) ([]Booking, error) {
	query := `
		SELECT id, user_id, facility_id, start_time, end_time, status, created_at
		FROM bookings
		WHERE user_id = $1
		ORDER BY start_time DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var bookings []Booking
	for rows.Next() {
		var booking Booking
		if err := rows.Scan(&booking.ID, &booking.UserID, &booking.FacilityID, &booking.StartTime, &booking.EndTime, &booking.Status, &booking.CreatedAt); err != nil {
			return nil, err
		}
		bookings = append(bookings, booking)
	}

	return bookings, rows.Err()
}
