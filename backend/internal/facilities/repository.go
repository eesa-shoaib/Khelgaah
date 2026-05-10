package facilities

import (
	"context"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	List(ctx context.Context, query string) ([]Facility, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) List(ctx context.Context, search string) ([]Facility, error) {
	query := `
		SELECT f.id, f.venue_id, v.name, v.city, f.name, f.sport, f.type, f.open_summary, 
		       COALESCE(f.price_per_hour::text, '0'), COALESCE(f.open_time::text, ''), 
		       COALESCE(f.close_time::text, ''), COALESCE(f.slot_duration_mins, 60), f.status
		FROM facilities f
		JOIN venues v ON f.venue_id = v.id
		WHERE f.status = 'active'
		  AND v.approval_status = 'approved'
		  AND ($1 = '' OR LOWER(f.name) LIKE '%' || $1 || '%' OR LOWER(f.sport) LIKE '%' || $1 || '%' OR LOWER(f.type) LIKE '%' || $1 || '%')
		ORDER BY f.name
	`
	rows, err := r.db.Query(ctx, query, strings.ToLower(strings.TrimSpace(search)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var facilities []Facility
	for rows.Next() {
		var facility Facility
		if err := rows.Scan(
			&facility.ID, &facility.VenueID, &facility.VenueName, &facility.VenueCity,
			&facility.Name, &facility.Sport, &facility.Type, &facility.OpenSummary,
			&facility.PricePerHour, &facility.OpenTime, &facility.CloseTime,
			&facility.SlotDurationMins, &facility.Status,
		); err != nil {
			return nil, err
		}
		facilities = append(facilities, facility)
	}

	return facilities, rows.Err()
}
