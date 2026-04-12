package availability

import (
	"context"
	"errors"
	"fmt"
	"time"
)

var ErrInvalidAvailabilityRequest = errors.New("invalid availability request")

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListSlots(ctx context.Context, facilityID int64, date string, duration int) ([]Slot, error) {
	if facilityID <= 0 {
		return nil, fmt.Errorf("%w: facility_id must be positive", ErrInvalidAvailabilityRequest)
	}
	if duration <= 0 {
		return nil, fmt.Errorf("%w: duration must be positive", ErrInvalidAvailabilityRequest)
	}

	day, err := time.Parse("2006-01-02", date)
	if err != nil {
		return nil, fmt.Errorf("%w: date must use YYYY-MM-DD", ErrInvalidAvailabilityRequest)
	}
	return s.repo.ListSlots(ctx, facilityID, day, duration)
}
