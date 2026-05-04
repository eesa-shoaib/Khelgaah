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
		SELECT
			ts.starts_at,
			ts.ends_at,
			CASE 
				WHEN b.id IS NOT NULL AND b.status = 'confirmed' THEN 'booked'
				WHEN ts.slot_type = 'blocked' THEN 'blocked'
				ELSE 'available'
			END AS status
		FROM time_slots ts
		LEFT JOIN bookings b ON b.facility_id = ts.facility_id
			AND b.status = 'confirmed'
			AND b.start_time < ts.ends_at
			AND b.end_time > ts.starts_at
		WHERE ts.facility_id = $1
			AND ts.status = 'active'
			AND ts.starts_at >= $2::date
			AND ts.starts_at < $2::date + interval '1 day'
		ORDER BY ts.starts_at
	`

	rows, err := r.db.Query(ctx, query, facilityID, day)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var slots []Slot
	for rows.Next() {
		var slot Slot
		var status string
		if err := rows.Scan(&slot.StartTime, &slot.EndTime, &status); err != nil {
			return nil, err
		}
		slot.IsAvailable = status == "available"
		slot.Status = status
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
			  AND status IN ('pending', 'confirmed', 'completed')
			  AND tstzrange(start_time, end_time, '[)') && tstzrange($2, $3, '[)')
		)
		OR EXISTS (
			SELECT 1
			FROM time_slots
			WHERE facility_id = $1
			  AND slot_type = 'blocked'
			  AND status = 'active'
			  AND tstzrange(starts_at, ends_at, '[)') && tstzrange($2, $3, '[)')
		)
	`

	var exists bool
	err := q.QueryRow(ctx, query, facilityID, start, end).Scan(&exists)
	return exists, err
}
