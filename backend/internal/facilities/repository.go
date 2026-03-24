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
		SELECT id, venue_id, name, sport, type, open_summary
		FROM facilities
		WHERE ($1 = '' OR LOWER(name) LIKE '%' || $1 || '%' OR LOWER(sport) LIKE '%' || $1 || '%' OR LOWER(type) LIKE '%' || $1 || '%')
		ORDER BY name
	`
	rows, err := r.db.Query(ctx, query, strings.ToLower(strings.TrimSpace(search)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var facilities []Facility
	for rows.Next() {
		var facility Facility
		if err := rows.Scan(&facility.ID, &facility.VenueID, &facility.Name, &facility.Sport, &facility.Type, &facility.OpenSummary); err != nil {
			return nil, err
		}
		facilities = append(facilities, facility)
	}

	return facilities, rows.Err()
}
