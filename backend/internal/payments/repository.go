package payments

import (
	"context"
	"errors"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrPaymentNotFound = errors.New("payment or booking not found")

type Repository interface {
	List(ctx context.Context, filter ListFilter) ([]Payment, error)
	RefundByBooking(ctx context.Context, bookingID int64, notes string) (Payment, error)
	Analytics(ctx context.Context) (Analytics, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) List(ctx context.Context, filter ListFilter) ([]Payment, error) {
	query := `
		SELECT id, booking_id, amount::text, currency, method, status, provider_reference, notes, paid_at, refunded_at, created_at, updated_at
		FROM payments
		WHERE ($1 = '' OR status = $1)
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, strings.TrimSpace(strings.ToLower(filter.Status)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []Payment
	for rows.Next() {
		var payment Payment
		if err := rows.Scan(
			&payment.ID,
			&payment.BookingID,
			&payment.Amount,
			&payment.Currency,
			&payment.Method,
			&payment.Status,
			&payment.ProviderReference,
			&payment.Notes,
			&payment.PaidAt,
			&payment.RefundedAt,
			&payment.CreatedAt,
			&payment.UpdatedAt,
		); err != nil {
			return nil, err
		}
		items = append(items, payment)
	}

	return items, rows.Err()
}

func (r *repository) RefundByBooking(ctx context.Context, bookingID int64, notes string) (Payment, error) {
	query := `
		UPDATE payments
		SET status = 'refunded',
		    refunded_at = NOW(),
		    updated_at = NOW(),
		    notes = CASE WHEN notes = '' THEN $2 ELSE notes || E'\n' || $2 END
		WHERE booking_id = $1
		  AND status IN ('paid', 'pending')
		RETURNING id, booking_id, amount::text, currency, method, status, provider_reference, notes, paid_at, refunded_at, created_at, updated_at
	`

	var payment Payment
	err := r.db.QueryRow(ctx, query, bookingID, notes).Scan(
		&payment.ID,
		&payment.BookingID,
		&payment.Amount,
		&payment.Currency,
		&payment.Method,
		&payment.Status,
		&payment.ProviderReference,
		&payment.Notes,
		&payment.PaidAt,
		&payment.RefundedAt,
		&payment.CreatedAt,
		&payment.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Payment{}, ErrPaymentNotFound
		}
		return Payment{}, err
	}

	_, err = r.db.Exec(ctx, `
		UPDATE bookings
		SET status = CASE WHEN status = 'completed' THEN status ELSE 'cancelled' END,
		    cancelled_at = CASE WHEN status = 'completed' THEN cancelled_at ELSE NOW() END,
		    updated_at = NOW()
		WHERE id = $1
	`, bookingID)
	if err != nil {
		return Payment{}, err
	}

	return payment, nil
}

func (r *repository) Analytics(ctx context.Context) (Analytics, error) {
	query := `
		SELECT
			COUNT(*)::bigint,
			COALESCE(SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END), 0)::text,
			COALESCE(SUM(CASE WHEN status = 'refunded' THEN amount ELSE 0 END), 0)::text,
			COUNT(*) FILTER (WHERE status = 'pending')::bigint
		FROM payments
	`

	var analytics Analytics
	err := r.db.QueryRow(ctx, query).Scan(
		&analytics.TotalTransactions,
		&analytics.TotalPaidAmount,
		&analytics.TotalRefunded,
		&analytics.PendingCount,
	)
	return analytics, err
}
