package availability

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	ListSlots(ctx context.Context, facilityID int64, day time.Time, durationMinutes int) ([]Slot, error)
	HasConflict(ctx context.Context, q Querier, facilityID int64, start, end time.Time) (bool, error)
}

type Querier interface {
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) ListSlots(ctx context.Context, facilityID int64, day time.Time, durationMinutes int) ([]Slot, error) {
	query := `
		WITH operating AS (
			SELECT opens_at, closes_at
			FROM facility_operating_hours
			WHERE facility_id = $1 AND weekday = EXTRACT(DOW FROM $2::date)
		),
		candidate_slots AS (
			SELECT
				generate_series(
					$2::date + operating.opens_at,
					$2::date + operating.closes_at - make_interval(mins => $3),
					interval '1 hour'
				) AS start_time
			FROM operating
		)
		SELECT
			cs.start_time,
			cs.start_time + make_interval(mins => $3) AS end_time,
			NOT EXISTS (
				SELECT 1
				FROM bookings b
				WHERE b.facility_id = $1
				  AND b.status = 'confirmed'
				  AND tstzrange(b.start_time, b.end_time, '[)') && tstzrange(cs.start_time, cs.start_time + make_interval(mins => $3), '[)')
			) AS is_available
		FROM candidate_slots cs
		ORDER BY cs.start_time
	`

	rows, err := r.db.Query(ctx, query, facilityID, day, durationMinutes)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var slots []Slot
	for rows.Next() {
		var slot Slot
		if err := rows.Scan(&slot.StartTime, &slot.EndTime, &slot.IsAvailable); err != nil {
			return nil, err
		}
		slots = append(slots, slot)
	}

	return slots, rows.Err()
}

func (r *repository) HasConflict(ctx context.Context, q Querier, facilityID int64, start, end time.Time) (bool, error) {
	query := `
		SELECT EXISTS (
			SELECT 1
			FROM bookings
			WHERE facility_id = $1
			  AND status = 'confirmed'
			  AND tstzrange(start_time, end_time, '[)') && tstzrange($2, $3, '[)')
		)
	`

	var exists bool
	err := q.QueryRow(ctx, query, facilityID, start, end).Scan(&exists)
	return exists, err
}
