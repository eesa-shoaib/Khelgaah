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
	dayStart := time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, day.Location())
	dayEnd := dayStart.Add(24 * time.Hour)

	ownerWindows, err := r.loadOwnerWindows(ctx, facilityID, dayStart, dayEnd)
	if err != nil {
		return nil, err
	}

	blockedWindows, err := r.loadBlockedWindows(ctx, facilityID, dayStart, dayEnd)
	if err != nil {
		return nil, err
	}

	slotDurationMins := durationMinutes
	if slotDurationMins <= 0 {
		slotDurationMins = 60
	}

	if len(ownerWindows) > 0 {
		return generateSlotsFromWindows(ownerWindows, blockedWindows, slotDurationMins), nil
	}

	return nil, nil
}

func mapStatus(isAvailable bool) string {
	if isAvailable {
		return "available"
	}
	return "blocked"
}

type timeWindow struct {
	start time.Time
	end   time.Time
}

func (r *repository) loadOwnerWindows(ctx context.Context, facilityID int64, dayStart, dayEnd time.Time) ([]timeWindow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT starts_at, ends_at
		FROM time_slots
		WHERE facility_id = $1
		  AND slot_type = 'available'
		  AND status = 'active'
		  AND starts_at >= $2
		  AND starts_at < $3
		ORDER BY starts_at
	`, facilityID, dayStart, dayEnd)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var windows []timeWindow
	for rows.Next() {
		var startTS, endTS time.Time
		if err := rows.Scan(&startTS, &endTS); err != nil {
			return nil, err
		}
		windows = append(windows, timeWindow{start: startTS, end: endTS})
	}
	return windows, rows.Err()
}

func (r *repository) loadBlockedWindows(ctx context.Context, facilityID int64, dayStart, dayEnd time.Time) ([]timeWindow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT b.start_time, b.end_time
		FROM bookings b
		WHERE b.facility_id = $1
		  AND b.status IN ('pending', 'confirmed', 'completed')
		  AND b.start_time < $3
		  AND b.end_time > $2
		UNION ALL
		SELECT ts.starts_at, ts.ends_at
		FROM time_slots ts
		WHERE ts.facility_id = $1
		  AND ts.slot_type = 'blocked'
		  AND ts.status = 'active'
		  AND ts.starts_at < $3
		  AND ts.ends_at > $2
		ORDER BY 1
	`, facilityID, dayStart, dayEnd)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var windows []timeWindow
	for rows.Next() {
		var startTS, endTS time.Time
		if err := rows.Scan(&startTS, &endTS); err != nil {
			return nil, err
		}
		windows = append(windows, timeWindow{start: startTS, end: endTS})
	}
	return windows, rows.Err()
}

func generateSlotsFromWindows(windows []timeWindow, blockedWindows []timeWindow, durationMinutes int) []Slot {
	var slots []Slot
	slotDuration := time.Duration(durationMinutes) * time.Minute

	for _, window := range windows {
		current := window.start
		for {
			slotEnd := current.Add(slotDuration)
			if slotEnd.After(window.end) {
				break
			}

			isAvailable := !hasOverlap(current, slotEnd, blockedWindows)
			slots = append(slots, Slot{
				StartTime:   current,
				EndTime:     slotEnd,
				IsAvailable: isAvailable,
				Status:      mapStatus(isAvailable),
			})

			current = slotEnd
		}
	}

	return slots
}

func hasOverlap(start, end time.Time, windows []timeWindow) bool {
	for _, window := range windows {
		if start.Before(window.end) && end.After(window.start) {
			return true
		}
	}
	return false
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
