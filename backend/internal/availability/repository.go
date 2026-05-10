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
	var slots []Slot

	var opensAt, closesAt string
	var slotDurationMins int
	var hasOperatingHours bool

	checkHoursQuery := `
		SELECT opens_at::text, closes_at::text, slot_duration_mins
		FROM facility_operating_hours
		WHERE facility_id = $1 AND weekday = $2
	`
	err := r.db.QueryRow(ctx, checkHoursQuery, facilityID, day.Weekday()).Scan(&opensAt, &closesAt, &slotDurationMins)
	if err == nil {
		hasOperatingHours = true
	} else if err != pgx.ErrNoRows {
		return nil, err
	}

	if !hasOperatingHours {
		return slots, nil
	}

	openTime, err := parseTimeOfDay(opensAt)
	if err != nil {
		return nil, err
	}
	closeTime, err := parseTimeOfDay(closesAt)
	if err != nil {
		return nil, err
	}

	if slotDurationMins <= 0 {
		slotDurationMins = 60
	}

	dayStart := time.Date(day.Year(), day.Month(), day.Day(), openTime.Hour(), openTime.Minute(), 0, 0, day.Location())
	dayEnd := time.Date(day.Year(), day.Month(), day.Day(), closeTime.Hour(), closeTime.Minute(), 0, 0, day.Location())

	conflictQuery := `
		SELECT b.start_time, b.end_time FROM bookings b
		WHERE b.facility_id = $1
		  AND b.status IN ('pending', 'confirmed', 'completed')
		  AND b.start_time < $3 AND b.end_time > $2
		UNION ALL
		SELECT ts.starts_at, ts.ends_at FROM time_slots ts
		WHERE ts.facility_id = $1
		  AND ts.slot_type = 'blocked'
		  AND ts.status = 'active'
		  AND ts.starts_at < $3 AND ts.ends_at > $2
	`

	blockedMap := make(map[string]bool)
	rows, err := r.db.Query(ctx, conflictQuery, facilityID, dayStart, dayEnd)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var startTS, endTS time.Time
	for rows.Next() {
		if err := rows.Scan(&startTS, &endTS); err != nil {
			return nil, err
		}
		current := startTS
		for current.Before(endTS) {
			key := current.Format(time.RFC3339)
			blockedMap[key] = true
			current = current.Add(time.Minute)
		}
	}

	current := dayStart
	for current.Add(time.Duration(slotDurationMins) * time.Minute).Before(dayEnd) || current.Add(time.Duration(slotDurationMins) * time.Minute).Equal(dayEnd) {
		slotEnd := current.Add(time.Duration(slotDurationMins) * time.Minute)
		if slotEnd.After(dayEnd) {
			break
		}

		isAvailable := !blockedMap[current.Format(time.RFC3339)]
		status := "available"
		if !isAvailable {
			status = "blocked"
		}

		slots = append(slots, Slot{
			StartTime:   current,
			EndTime:     slotEnd,
			IsAvailable: isAvailable,
			Status:      status,
		})

		current = slotEnd
	}

	return slots, nil
}

func parseTimeOfDay(s string) (time.Time, error) {
	base := time.Date(2000, 1, 1, 0, 0, 0, 0, time.UTC)
	if len(s) == 5 {
		base, _ = time.Parse("15:04", s)
	} else if len(s) == 8 {
		base, _ = time.Parse("15:04:05", s)
	}
	return base, nil
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
