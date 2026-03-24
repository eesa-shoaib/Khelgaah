package bookings

import (
	"context"
	"errors"
	"time"

	"github.com/eesa/khelgaah/backend/internal/availability"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var ErrSlotUnavailable = errors.New("selected slot is no longer available")

type Service struct {
	db               *pgxpool.Pool
	repo             Repository
	availabilityRepo availability.Repository
}

func NewService(db *pgxpool.Pool, repo Repository, availabilityRepo availability.Repository) *Service {
	return &Service{db: db, repo: repo, availabilityRepo: availabilityRepo}
}

func (s *Service) Create(ctx context.Context, userID int64, input CreateBookingInput) (Booking, error) {
	start, err := time.Parse(time.RFC3339, input.StartTime)
	if err != nil {
		return Booking{}, err
	}
	end, err := time.Parse(time.RFC3339, input.EndTime)
	if err != nil {
		return Booking{}, err
	}

	tx, err := s.db.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Booking{}, err
	}
	defer tx.Rollback(ctx)

	conflict, err := s.availabilityRepo.HasConflict(ctx, tx, input.FacilityID, start, end)
	if err != nil {
		return Booking{}, err
	}
	if conflict {
		return Booking{}, ErrSlotUnavailable
	}

	booking, err := s.repo.Create(ctx, tx, userID, input.FacilityID, start, end)
	if err != nil {
		return Booking{}, err
	}

	if err := tx.Commit(ctx); err != nil {
		return Booking{}, err
	}

	return booking, nil
}

func (s *Service) ListByUser(ctx context.Context, userID int64) ([]Booking, error) {
	return s.repo.ListByUser(ctx, userID)
}
