package venue_owner

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrNotFound = errors.New("resource not found")

type Repository interface {
	CreateVenue(ctx context.Context, ownerID int64, input VenueInput) (Venue, error)
	ListVenues(ctx context.Context, ownerID int64) ([]Venue, error)
	GetVenue(ctx context.Context, ownerID, venueID int64) (Venue, error)
	UpdateVenue(ctx context.Context, ownerID, venueID int64, input VenueInput) (Venue, error)
	DeleteVenue(ctx context.Context, ownerID, venueID int64) error
	CreateFacility(ctx context.Context, ownerID, venueID int64, input FacilityInput) (Facility, error)
	ListFacilities(ctx context.Context, ownerID, venueID int64) ([]Facility, error)
	UpdateFacility(ctx context.Context, ownerID, facilityID int64, input FacilityInput) (Facility, error)
	DeleteFacility(ctx context.Context, ownerID, facilityID int64) error
	CreateTimeSlot(ctx context.Context, ownerID, facilityID int64, input TimeSlotInput) (TimeSlot, error)
	ListAvailability(ctx context.Context, ownerID, facilityID int64, from, to time.Time) ([]TimeSlot, error)
	UpdateTimeSlot(ctx context.Context, ownerID, slotID int64, input TimeSlotInput) (TimeSlot, error)
	DeleteTimeSlot(ctx context.Context, ownerID, slotID int64) error
	BlockDates(ctx context.Context, ownerID, facilityID int64, input BlockDatesInput) ([]TimeSlot, error)
	ListBookings(ctx context.Context, ownerID int64, status string) ([]Booking, error)
	GetBooking(ctx context.Context, ownerID, bookingID int64) (Booking, error)
	UpdateBookingStatus(ctx context.Context, ownerID, bookingID int64, status, notes string) (Booking, error)
	Dashboard(ctx context.Context, ownerID int64) (DashboardStats, error)
	Analytics(ctx context.Context, ownerID int64, days int) ([]AnalyticsPoint, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) CreateVenue(ctx context.Context, ownerID int64, input VenueInput) (Venue, error) {
	query := `
		INSERT INTO venues (owner_user_id, name, city, address, latitude, longitude, approval_status)
		VALUES ($1, $2, $3, $4, $5, $6, 'pending')
		RETURNING id, owner_user_id, name, city, address, latitude, longitude, approval_status, created_at, updated_at, suspended_at
	`
	return scanVenue(r.db.QueryRow(ctx, query, ownerID, input.Name, input.City, input.Address, input.Latitude, input.Longitude))
}

func (r *repository) ListVenues(ctx context.Context, ownerID int64) ([]Venue, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, owner_user_id, name, city, address, latitude, longitude, approval_status, created_at, updated_at, suspended_at
		FROM venues
		WHERE owner_user_id = $1
		ORDER BY created_at DESC
	`, ownerID)
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

func (r *repository) GetVenue(ctx context.Context, ownerID, venueID int64) (Venue, error) {
	return scanVenue(r.db.QueryRow(ctx, `
		SELECT id, owner_user_id, name, city, address, latitude, longitude, approval_status, created_at, updated_at, suspended_at
		FROM venues
		WHERE id = $1 AND owner_user_id = $2
	`, venueID, ownerID))
}

func (r *repository) UpdateVenue(ctx context.Context, ownerID, venueID int64, input VenueInput) (Venue, error) {
	return scanVenue(r.db.QueryRow(ctx, `
		UPDATE venues
		SET name = $3, city = $4, address = $5, latitude = $6, longitude = $7, updated_at = NOW()
		WHERE id = $1 AND owner_user_id = $2
		RETURNING id, owner_user_id, name, city, address, latitude, longitude, approval_status, created_at, updated_at, suspended_at
	`, venueID, ownerID, input.Name, input.City, input.Address, input.Latitude, input.Longitude))
}

func (r *repository) DeleteVenue(ctx context.Context, ownerID, venueID int64) error {
	tag, err := r.db.Exec(ctx, `DELETE FROM venues WHERE id = $1 AND owner_user_id = $2`, venueID, ownerID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *repository) CreateFacility(ctx context.Context, ownerID, venueID int64, input FacilityInput) (Facility, error) {
	query := `
		INSERT INTO facilities (venue_id, name, sport, type, open_summary, price_per_hour, status, open_time, close_time, slot_duration_mins)
		SELECT id, $3, $4, $5, $6, $7::numeric, $8, $9, $10, $11
		FROM venues
		WHERE id = $1 AND owner_user_id = $2
		RETURNING id, venue_id, name, sport, type, open_summary, price_per_hour::text, status, open_time, close_time, slot_duration_mins, created_at, updated_at
	`
	return scanFacility(r.db.QueryRow(ctx, query, venueID, ownerID, input.Name, input.Sport, input.Type, input.OpenSummary, input.PricePerHour, input.Status, input.OpenTime, input.CloseTime, input.SlotDurationMins))
}

func (r *repository) ListFacilities(ctx context.Context, ownerID, venueID int64) ([]Facility, error) {
	rows, err := r.db.Query(ctx, `
		SELECT f.id, f.venue_id, f.name, f.sport, f.type, COALESCE(f.open_summary, ''), COALESCE(f.price_per_hour::text, '0'), COALESCE(f.status, 'active'), f.open_time, f.close_time, f.slot_duration_mins, f.created_at, f.updated_at
		FROM facilities f
		JOIN venues v ON v.id = f.venue_id
		WHERE f.venue_id = $1 AND v.owner_user_id = $2
		ORDER BY f.name
	`, venueID, ownerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []Facility
	for rows.Next() {
		item, err := scanFacility(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *repository) UpdateFacility(ctx context.Context, ownerID, facilityID int64, input FacilityInput) (Facility, error) {
	query := `
		UPDATE facilities f
		SET name = $3, sport = $4, type = $5, open_summary = $6, price_per_hour = $7::numeric, status = $8, open_time = $9, close_time = $10, slot_duration_mins = $11, updated_at = NOW()
		FROM venues v
		WHERE f.id = $1 AND f.venue_id = v.id AND v.owner_user_id = $2
		RETURNING f.id, f.venue_id, f.name, f.sport, f.type, f.open_summary, f.price_per_hour::text, f.status, f.open_time, f.close_time, f.slot_duration_mins, f.created_at, f.updated_at
	`
	return scanFacility(r.db.QueryRow(ctx, query, facilityID, ownerID, input.Name, input.Sport, input.Type, input.OpenSummary, input.PricePerHour, input.Status, input.OpenTime, input.CloseTime, input.SlotDurationMins))
}

func (r *repository) DeleteFacility(ctx context.Context, ownerID, facilityID int64) error {
	tag, err := r.db.Exec(ctx, `
		DELETE FROM facilities f
		USING venues v
		WHERE f.id = $1 AND f.venue_id = v.id AND v.owner_user_id = $2
	`, facilityID, ownerID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *repository) CreateTimeSlot(ctx context.Context, ownerID, facilityID int64, input TimeSlotInput) (TimeSlot, error) {
	query := `
		INSERT INTO time_slots (facility_id, starts_at, ends_at, slot_type, status, reason, created_by_user_id)
		SELECT f.id, $3::timestamptz, $4::timestamptz, $5, $6, $7, $2
		FROM facilities f
		JOIN venues v ON v.id = f.venue_id
		WHERE f.id = $1 AND v.owner_user_id = $2
		RETURNING id, facility_id, starts_at, ends_at, slot_type, status, reason, created_by_user_id, created_at, updated_at
	`
	return scanTimeSlot(r.db.QueryRow(ctx, query, facilityID, ownerID, input.StartsAt, input.EndsAt, input.SlotType, input.Status, input.Reason))
}

func (r *repository) ListAvailability(ctx context.Context, ownerID, facilityID int64, from, to time.Time) ([]TimeSlot, error) {
	rows, err := r.db.Query(ctx, `
		SELECT ts.id, ts.facility_id, ts.starts_at, ts.ends_at, ts.slot_type, ts.status, ts.reason, ts.created_by_user_id, ts.created_at, ts.updated_at
		FROM time_slots ts
		JOIN facilities f ON f.id = ts.facility_id
		JOIN venues v ON v.id = f.venue_id
		WHERE ts.facility_id = $1
		  AND v.owner_user_id = $2
		  AND ts.starts_at >= $3
		  AND ts.ends_at <= $4
		ORDER BY ts.starts_at
	`, facilityID, ownerID, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []TimeSlot
	for rows.Next() {
		item, err := scanTimeSlot(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *repository) UpdateTimeSlot(ctx context.Context, ownerID, slotID int64, input TimeSlotInput) (TimeSlot, error) {
	query := `
		UPDATE time_slots ts
		SET starts_at = $3::timestamptz,
		    ends_at = $4::timestamptz,
		    slot_type = $5,
		    status = $6,
		    reason = $7,
		    updated_at = NOW()
		FROM facilities f
		JOIN venues v ON v.id = f.venue_id
		WHERE ts.id = $1 AND ts.facility_id = f.id AND v.owner_user_id = $2
		RETURNING ts.id, ts.facility_id, ts.starts_at, ts.ends_at, ts.slot_type, ts.status, ts.reason, ts.created_by_user_id, ts.created_at, ts.updated_at
	`
	return scanTimeSlot(r.db.QueryRow(ctx, query, slotID, ownerID, input.StartsAt, input.EndsAt, input.SlotType, input.Status, input.Reason))
}

func (r *repository) DeleteTimeSlot(ctx context.Context, ownerID, slotID int64) error {
	query := `
		DELETE FROM time_slots ts
		USING facilities f
		JOIN venues v ON v.id = f.venue_id
		WHERE ts.id = $1 AND ts.facility_id = f.id AND v.owner_user_id = $2
	`
	result, err := r.db.Exec(ctx, query, slotID, ownerID)
	if err != nil {
		return err
	}
	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return ErrNotFound
	}
	return nil
}

func (r *repository) BlockDates(ctx context.Context, ownerID, facilityID int64, input BlockDatesInput) ([]TimeSlot, error) {
	rows, err := r.db.Query(ctx, `
		WITH days AS (
			SELECT generate_series($3::date, $4::date, interval '1 day')::date AS day
		),
		inserted AS (
			INSERT INTO time_slots (facility_id, starts_at, ends_at, slot_type, status, reason, created_by_user_id)
			SELECT
				f.id,
				d.day::timestamptz,
				(d.day + interval '1 day')::timestamptz,
				'blocked',
				'active',
				$5,
				$2
			FROM facilities f
			JOIN venues v ON v.id = f.venue_id
			CROSS JOIN days d
			WHERE f.id = $1 AND v.owner_user_id = $2
			RETURNING id, facility_id, starts_at, ends_at, slot_type, status, reason, created_by_user_id, created_at, updated_at
		)
		SELECT id, facility_id, starts_at, ends_at, slot_type, status, reason, created_by_user_id, created_at, updated_at
		FROM inserted
		ORDER BY starts_at
	`, facilityID, ownerID, input.StartDate, input.EndDate, input.Reason)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []TimeSlot
	for rows.Next() {
		item, err := scanTimeSlot(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func (r *repository) ListBookings(ctx context.Context, ownerID int64, status string) ([]Booking, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			b.id, b.user_id, b.facility_id, f.name, v.id, v.name,
			u.full_name, u.email, b.start_time, b.end_time, b.status, b.notes,
			COALESCE(p.status, 'pending'), COALESCE(p.amount::text, '0'),
			b.created_at, b.updated_at
		FROM bookings b
		JOIN facilities f ON f.id = b.facility_id
		JOIN venues v ON v.id = f.venue_id
		JOIN users u ON u.id = b.user_id
		LEFT JOIN LATERAL (
			SELECT status, amount
			FROM payments
			WHERE booking_id = b.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
		WHERE v.owner_user_id = $1
		  AND ($2 = '' OR b.status = $2)
		ORDER BY b.start_time DESC
	`, ownerID, strings.TrimSpace(strings.ToLower(status)))
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

func (r *repository) GetBooking(ctx context.Context, ownerID, bookingID int64) (Booking, error) {
	return scanBooking(r.db.QueryRow(ctx, `
		SELECT
			b.id, b.user_id, b.facility_id, f.name, v.id, v.name,
			u.full_name, u.email, b.start_time, b.end_time, b.status, b.notes,
			COALESCE(p.status, 'pending'), COALESCE(p.amount::text, '0'),
			b.created_at, b.updated_at
		FROM bookings b
		JOIN facilities f ON f.id = b.facility_id
		JOIN venues v ON v.id = f.venue_id
		JOIN users u ON u.id = b.user_id
		LEFT JOIN LATERAL (
			SELECT status, amount
			FROM payments
			WHERE booking_id = b.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
		WHERE b.id = $1 AND v.owner_user_id = $2
	`, bookingID, ownerID))
}

func (r *repository) UpdateBookingStatus(ctx context.Context, ownerID, bookingID int64, status, notes string) (Booking, error) {
	return scanBooking(r.db.QueryRow(ctx, `
		WITH updated AS (
			UPDATE bookings b
			SET status = $3,
			    notes = CASE WHEN $4 = '' THEN b.notes ELSE $4 END,
			    approved_at = CASE WHEN $3 = 'confirmed' THEN NOW() ELSE b.approved_at END,
			    rejected_at = CASE WHEN $3 = 'rejected' THEN NOW() ELSE b.rejected_at END,
			    cancelled_at = CASE WHEN $3 = 'cancelled' THEN NOW() ELSE b.cancelled_at END,
			    updated_at = NOW()
			FROM facilities f
			JOIN venues v ON v.id = f.venue_id
			WHERE b.id = $1 AND b.facility_id = f.id AND v.owner_user_id = $2
			RETURNING b.id, b.user_id, b.facility_id, b.start_time, b.end_time, b.status, b.notes, b.created_at, b.updated_at
		)
		SELECT
			u.id, u.user_id, u.facility_id, f.name, v.id, v.name,
			c.full_name, c.email, u.start_time, u.end_time, u.status, u.notes,
			COALESCE(p.status, 'pending'), COALESCE(p.amount::text, '0'),
			u.created_at, u.updated_at
		FROM updated u
		JOIN facilities f ON f.id = u.facility_id
		JOIN venues v ON v.id = f.venue_id
		JOIN users c ON c.id = u.user_id
		LEFT JOIN LATERAL (
			SELECT status, amount
			FROM payments
			WHERE booking_id = u.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
	`, bookingID, ownerID, status, notes))
}

func (r *repository) Dashboard(ctx context.Context, ownerID int64) (DashboardStats, error) {
	query := `
		WITH owner_bookings AS (
			SELECT b.*, COALESCE(p.amount, 0) AS amount, COALESCE(p.status, 'pending') AS payment_status
			FROM bookings b
			JOIN facilities f ON f.id = b.facility_id
			JOIN venues v ON v.id = f.venue_id
			LEFT JOIN LATERAL (
				SELECT amount, status
				FROM payments
				WHERE booking_id = b.id
				ORDER BY created_at DESC
				LIMIT 1
			) p ON true
			WHERE v.owner_user_id = $1
		)
		SELECT
			(SELECT COUNT(*) FROM venues WHERE owner_user_id = $1)::bigint,
			(SELECT COUNT(*) FROM facilities f JOIN venues v ON v.id = f.venue_id WHERE v.owner_user_id = $1)::bigint,
			COUNT(*)::bigint,
			COALESCE(SUM(CASE WHEN payment_status = 'paid' THEN amount ELSE 0 END), 0)::text,
			COALESCE(ROUND((COUNT(*) FILTER (WHERE status IN ('pending', 'confirmed', 'completed'))::numeric / NULLIF(COUNT(*)::numeric, 0)) * 100, 2), 0)::text
		FROM owner_bookings
	`

	var stats DashboardStats
	err := r.db.QueryRow(ctx, query, ownerID).Scan(
		&stats.TotalVenues,
		&stats.TotalFacilities,
		&stats.TotalBookings,
		&stats.Revenue,
		&stats.OccupancyRate,
	)
	return stats, err
}

func (r *repository) Analytics(ctx context.Context, ownerID int64, days int) ([]AnalyticsPoint, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			TO_CHAR(DATE_TRUNC('day', b.start_time), 'YYYY-MM-DD') AS day,
			COUNT(*)::bigint,
			COALESCE(SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END), 0)::text
		FROM bookings b
		JOIN facilities f ON f.id = b.facility_id
		JOIN venues v ON v.id = f.venue_id
		LEFT JOIN LATERAL (
			SELECT status, amount
			FROM payments
			WHERE booking_id = b.id
			ORDER BY created_at DESC
			LIMIT 1
		) p ON true
		WHERE v.owner_user_id = $1
		  AND b.start_time >= NOW() - make_interval(days => $2)
		GROUP BY 1
		ORDER BY 1 DESC
	`, ownerID, days)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var items []AnalyticsPoint
	for rows.Next() {
		var item AnalyticsPoint
		if err := rows.Scan(&item.Day, &item.Bookings, &item.Revenue); err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func scanVenue(row interface{ Scan(dest ...any) error }) (Venue, error) {
	var item Venue
	err := row.Scan(
		&item.ID,
		&item.OwnerUserID,
		&item.Name,
		&item.City,
		&item.Address,
		&item.Latitude,
		&item.Longitude,
		&item.ApprovalStatus,
		&item.CreatedAt,
		&item.UpdatedAt,
		&item.SuspendedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Venue{}, ErrNotFound
		}
		return Venue{}, err
	}
	return item, nil
}

func scanFacility(row interface{ Scan(dest ...any) error }) (Facility, error) {
	var openTime, closeTime *string
	var slotDurationMins *int
	var item Facility
	err := row.Scan(
		&item.ID,
		&item.VenueID,
		&item.Name,
		&item.Sport,
		&item.Type,
		&item.OpenSummary,
		&item.PricePerHour,
		&item.Status,
		&openTime,
		&closeTime,
		&slotDurationMins,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Facility{}, ErrNotFound
		}
		return Facility{}, err
	}
	item.OpenTime = openTime
	item.CloseTime = closeTime
	item.SlotDurationMins = slotDurationMins
	return item, nil
}

func scanTimeSlot(row interface{ Scan(dest ...any) error }) (TimeSlot, error) {
	var item TimeSlot
	err := row.Scan(
		&item.ID,
		&item.FacilityID,
		&item.StartsAt,
		&item.EndsAt,
		&item.SlotType,
		&item.Status,
		&item.Reason,
		&item.CreatedByUserID,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return TimeSlot{}, ErrNotFound
		}
		return TimeSlot{}, err
	}
	return item, nil
}

func scanBooking(row interface{ Scan(dest ...any) error }) (Booking, error) {
	var item Booking
	err := row.Scan(
		&item.ID,
		&item.UserID,
		&item.FacilityID,
		&item.FacilityName,
		&item.VenueID,
		&item.VenueName,
		&item.CustomerName,
		&item.CustomerEmail,
		&item.StartTime,
		&item.EndTime,
		&item.Status,
		&item.Notes,
		&item.PaymentStatus,
		&item.PaymentAmount,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Booking{}, ErrNotFound
		}
		return Booking{}, err
	}
	return item, nil
}
