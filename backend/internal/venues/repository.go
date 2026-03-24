package venues

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository interface {
	List(ctx context.Context) ([]Venue, error)
}

type repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) Repository {
	return &repository{db: db}
}

func (r *repository) List(ctx context.Context) ([]Venue, error) {
	query := `
		SELECT id, name, city, address, latitude, longitude
		FROM venues
		ORDER BY name
	`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var venues []Venue
	for rows.Next() {
		var venue Venue
		if err := rows.Scan(&venue.ID, &venue.Name, &venue.City, &venue.Address, &venue.Latitude, &venue.Longitude); err != nil {
			return nil, err
		}
		venues = append(venues, venue)
	}

	return venues, rows.Err()
}
