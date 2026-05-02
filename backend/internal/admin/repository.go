package admin

import (
	"context"
	"errors"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("resource not found")

type Repository interface {
	ListUsers(ctx context.Context, role, status string) ([]User, error)
	GetUser(ctx context.Context, userID int64) (User, error)
	ChangeUserRole(ctx context.Context, userID int64, role string) (User, error)
	SuspendUser(ctx context.Context, userID int64) (User, error)
	DeleteUser(ctx context.Context, userID int64) error
	ListVenues(ctx context.Context, status string) ([]Venue, error)
	UpdateVenueStatus(ctx context.Context, venueID int64, status string) (Venue, error)
	ListBookings(ctx context.Context, status string) ([]Booking, error)
	CancelBooking(ctx context.Context, bookingID int64, notes string) (Booking, error)
	ResolveDispute(ctx context.Context, bookingID int64, input ResolveDisputeInput) (Booking, error)
	Dashboard(ctx context.Context) (DashboardStats, error)
	Analytics(ctx context.Context) (Analytics, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) ListUsers(ctx context.Context, role, status string) ([]User, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, full_name, email, phone, role, status, created_at, updated_at, suspended_at
		FROM users
		WHERE ($1 = '' OR role = $1)
		  AND ($2 = '' OR status = $2)
		ORDER BY created_at DESC
	`, strings.TrimSpace(strings.ToLower(role)), strings.TrimSpace(strings.ToLower(status)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []User
	for rows.Next() {
		item, err := scanUser(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *repository) GetUser(ctx context.Context, userID int64) (User, error) {
	return scanUser(r.db.QueryRow(ctx, `
		SELECT id, full_name, email, phone, role, status, created_at, updated_at, suspended_at
		FROM users
		WHERE id = $1
	`, userID))
}

func (r *repository) ChangeUserRole(ctx context.Context, userID int64, role string) (User, error) {
	return scanUser(r.db.QueryRow(ctx, `
		UPDATE users
		SET role = $2, updated_at = NOW()
		WHERE id = $1
		RETURNING id, full_name, email, phone, role, status, created_at, updated_at, suspended_at
	`, userID, role))
}

func (r *repository) SuspendUser(ctx context.Context, userID int64) (User, error) {
	return scanUser(r.db.QueryRow(ctx, `
		UPDATE users
		SET status = 'suspended', suspended_at = NOW(), updated_at = NOW()
		WHERE id = $1
		RETURNING id, full_name, email, phone, role, status, created_at, updated_at, suspended_at
	`, userID))
}

func (r *repository) DeleteUser(ctx context.Context, userID int64) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE users
		SET status = 'deleted', updated_at = NOW()
		WHERE id = $1
	`, userID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *repository) ListVenues(ctx context.Context, status string) ([]Venue, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, owner_user_id, name, city, address, latitude, longitude, approval_status, created_at, updated_at, suspended_at
		FROM venues
		WHERE ($1 = '' OR approval_status = $1)
		ORDER BY created_at DESC
	`, strings.TrimSpace(strings.ToLower(status)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []Venue
	for rows.Next() {
		item, err := scanVenue(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *repository) UpdateVenueStatus(ctx context.Context, venueID int64, status string) (Venue, error) {
	suspendedAt := "NULL"
	if status == "suspended" {
		suspendedAt = "NOW()"
	}
	query := `
		UPDATE venues
		SET approval_status = $2,
		    suspended_at = ` + suspendedAt + `,
		    updated_at = NOW()
		WHERE id = $1
		RETURNING id, owner_user_id, name, city, address, latitude, longitude, approval_status, created_at, updated_at, suspended_at
	`
	return scanVenue(r.db.QueryRow(ctx, query, venueID, status))
}

func (r *repository) ListBookings(ctx context.Context, status string) ([]Booking, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			b.id, b.user_id, b.facility_id, u.full_name, f.name, v.name,
			b.start_time, b.end_time, b.status, b.notes,
			COALESCE(p.status, 'pending'),
			b.created_at, b.updated_at
		FROM bookings b
		JOIN users u ON u.id = b.user_id
		JOIN facilities f ON f.id = b.facility_id
		JOIN venues v ON v.id = f.venue_id
		LEFT JOIN LATERAL (
			SELECT status
			FROM payments
			WHERE booking_id = b.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
		WHERE ($1 = '' OR b.status = $1)
		ORDER BY b.created_at DESC
	`, strings.TrimSpace(strings.ToLower(status)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []Booking
	for rows.Next() {
		item, err := scanBooking(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *repository) CancelBooking(ctx context.Context, bookingID int64, notes string) (Booking, error) {
	return scanBooking(r.db.QueryRow(ctx, `
		WITH updated AS (
			UPDATE bookings
			SET status = 'cancelled',
			    notes = CASE WHEN notes = '' THEN $2 ELSE notes || E'\n' || $2 END,
			    cancelled_at = NOW(),
			    updated_at = NOW()
			WHERE id = $1
			RETURNING id, user_id, facility_id, start_time, end_time, status, notes, created_at, updated_at
		)
		SELECT
			u.id, u.user_id, u.facility_id, c.full_name, f.name, v.name,
			u.start_time, u.end_time, u.status, u.notes,
			COALESCE(p.status, 'pending'),
			u.created_at, u.updated_at
		FROM updated u
		JOIN users c ON c.id = u.user_id
		JOIN facilities f ON f.id = u.facility_id
		JOIN venues v ON v.id = f.venue_id
		LEFT JOIN LATERAL (
			SELECT status
			FROM payments
			WHERE booking_id = u.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
	`, bookingID, notes))
}

func (r *repository) ResolveDispute(ctx context.Context, bookingID int64, input ResolveDisputeInput) (Booking, error) {
	query := `
		WITH resolved AS (
			UPDATE disputes
			SET status = 'resolved',
			    resolution_notes = $2,
			    resolved_at = NOW(),
			    updated_at = NOW()
			WHERE booking_id = $1 AND status = 'open'
			RETURNING booking_id
		),
		updated_booking AS (
			UPDATE bookings
			SET status = CASE WHEN $3 = '' THEN status ELSE $3 END,
			    notes = CASE WHEN $2 = '' THEN notes ELSE $2 END,
			    updated_at = NOW()
			WHERE id = $1
			  AND EXISTS (SELECT 1 FROM resolved)
			RETURNING id, user_id, facility_id, start_time, end_time, status, notes, created_at, updated_at
		)
		SELECT
			b.id, b.user_id, b.facility_id, u.full_name, f.name, v.name,
			b.start_time, b.end_time, b.status, b.notes,
			COALESCE(p.status, 'pending'),
			b.created_at, b.updated_at
		FROM updated_booking b
		JOIN users u ON u.id = b.user_id
		JOIN facilities f ON f.id = b.facility_id
		JOIN venues v ON v.id = f.venue_id
		LEFT JOIN LATERAL (
			SELECT status
			FROM payments
			WHERE booking_id = b.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
	`
	return scanBooking(r.db.QueryRow(ctx, query, bookingID, input.ResolutionNotes, input.BookingStatus))
}

func (r *repository) Dashboard(ctx context.Context) (DashboardStats, error) {
	var stats DashboardStats
	err := r.db.QueryRow(ctx, `
		SELECT
			(SELECT COUNT(*) FROM users)::bigint,
			(SELECT COUNT(*) FROM venues)::bigint,
			(SELECT COUNT(*) FROM bookings)::bigint,
			(SELECT COALESCE(SUM(amount), 0)::text FROM payments WHERE status = 'paid'),
			(SELECT COUNT(*) FROM disputes WHERE status = 'open')::bigint,
			(SELECT COUNT(*) FROM venues WHERE approval_status = 'pending')::bigint,
			(SELECT COUNT(*) FROM bookings WHERE status = 'pending')::bigint
	`).Scan(
		&stats.TotalUsers,
		&stats.TotalVenues,
		&stats.TotalBookings,
		&stats.TotalRevenue,
		&stats.OpenDisputes,
		&stats.PendingVenues,
		&stats.PendingBookings,
	)
	return stats, err
}

func (r *repository) Analytics(ctx context.Context) (Analytics, error) {
	var result Analytics
	err := r.db.QueryRow(ctx, `
		SELECT
			COUNT(*) FILTER (WHERE role = 'customer' AND status = 'active')::bigint,
			COUNT(*) FILTER (WHERE role = 'venue_owner' AND status = 'active')::bigint,
			(SELECT COUNT(*) FROM bookings WHERE status = 'confirmed')::bigint,
			(SELECT COALESCE(SUM(amount), 0)::text FROM payments WHERE status = 'refunded')
		FROM users
	`).Scan(
		&result.ActiveCustomers,
		&result.ActiveOwners,
		&result.ConfirmedBookings,
		&result.RefundedAmount,
	)
	return result, err
}

func scanUser(row interface{ Scan(dest ...any) error }) (User, error) {
	var item User
	err := row.Scan(&item.ID, &item.FullName, &item.Email, &item.Phone, &item.Role, &item.Status, &item.CreatedAt, &item.UpdatedAt, &item.SuspendedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return User{}, ErrNotFound
		}
		return User{}, err
	}
	return item, nil
}

func scanVenue(row interface{ Scan(dest ...any) error }) (Venue, error) {
	var item Venue
	err := row.Scan(&item.ID, &item.OwnerUserID, &item.Name, &item.City, &item.Address, &item.Latitude, &item.Longitude, &item.ApprovalStatus, &item.CreatedAt, &item.UpdatedAt, &item.SuspendedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Venue{}, ErrNotFound
		}
		return Venue{}, err
	}
	return item, nil
}

func scanBooking(row interface{ Scan(dest ...any) error }) (Booking, error) {
	var item Booking
	err := row.Scan(&item.ID, &item.UserID, &item.FacilityID, &item.UserName, &item.FacilityName, &item.VenueName, &item.StartTime, &item.EndTime, &item.Status, &item.Notes, &item.PaymentStatus, &item.CreatedAt, &item.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Booking{}, ErrNotFound
		}
		return Booking{}, err
	}
	return item, nil
}
