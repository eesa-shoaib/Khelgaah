package bookings

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	Create(ctx context.Context, tx pgx.Tx, userID, facilityID int64, start, end time.Time) (Booking, error)
	ListByUser(ctx context.Context, userID int64) ([]Booking, error)
	Cancel(ctx context.Context, bookingID, userID int64) (Booking, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) Create(ctx context.Context, tx pgx.Tx, userID, facilityID int64, start, end time.Time) (Booking, error) {
	query := `
		WITH created_booking AS (
			INSERT INTO bookings (user_id, facility_id, start_time, end_time, status)
			VALUES ($1, $2, $3, $4, 'pending')
			RETURNING id, user_id, facility_id, start_time, end_time, status, notes, created_at, updated_at
		),
		created_payment AS (
			INSERT INTO payments (booking_id, amount, currency, method, status, notes)
			SELECT
				cb.id,
				ROUND((((EXTRACT(EPOCH FROM ($4 - $3)) / 3600.0) * f.price_per_hour))::numeric, 2),
				'PKR',
				'manual',
				'pending',
				'Auto-created when booking was submitted'
			FROM created_booking cb
			JOIN facilities f ON f.id = cb.facility_id
		)
		SELECT id, user_id, facility_id, start_time, end_time, status, notes, created_at, updated_at
		FROM created_booking
	`

	var booking Booking
	err := tx.QueryRow(ctx, query, userID, facilityID, start, end).
		Scan(
			&booking.ID,
			&booking.UserID,
			&booking.FacilityID,
			&booking.StartTime,
			&booking.EndTime,
			&booking.Status,
			&booking.Notes,
			&booking.CreatedAt,
			&booking.UpdatedAt,
		)
	return booking, err
}

func (r *repository) ListByUser(ctx context.Context, userID int64) ([]Booking, error) {
	query := `
		SELECT id, user_id, facility_id, start_time, end_time, status, notes, created_at, updated_at
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
		if err := rows.Scan(
			&booking.ID,
			&booking.UserID,
			&booking.FacilityID,
			&booking.StartTime,
			&booking.EndTime,
			&booking.Status,
			&booking.Notes,
			&booking.CreatedAt,
			&booking.UpdatedAt,
		); err != nil {
			return nil, err
		}
		bookings = append(bookings, booking)
	}

	return bookings, rows.Err()
}

func (r *repository) Cancel(ctx context.Context, bookingID, userID int64) (Booking, error) {
	query := `
		UPDATE bookings
		SET status = 'cancelled', cancelled_at = NOW(), updated_at = NOW()
		WHERE id = $1 AND user_id = $2 AND status IN ('pending', 'confirmed')
		RETURNING id, user_id, facility_id, start_time, end_time, status, notes, created_at, updated_at
	`

	var booking Booking
	err := r.db.QueryRow(ctx, query, bookingID, userID).Scan(
		&booking.ID,
		&booking.UserID,
		&booking.FacilityID,
		&booking.StartTime,
		&booking.EndTime,
		&booking.Status,
		&booking.Notes,
		&booking.CreatedAt,
		&booking.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Booking{}, ErrBookingNotFound
		}
		return Booking{}, err
	}

	_, err = r.db.Exec(ctx, `
		UPDATE payments
		SET status = CASE WHEN status = 'paid' THEN 'refunded' ELSE status END,
		    refunded_at = CASE WHEN status = 'paid' THEN NOW() ELSE refunded_at END,
		    updated_at = NOW(),
		    notes = CASE WHEN status = 'paid' THEN 'Refunded because customer cancelled booking' ELSE notes END
		WHERE booking_id = $1
	`, bookingID)
	if err != nil {
		return Booking{}, err
	}

	return booking, nil
}
