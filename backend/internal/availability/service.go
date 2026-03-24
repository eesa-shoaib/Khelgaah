package availability

import (
	"context"
	"time"
)

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListSlots(ctx context.Context, facilityID int64, date string, duration int) ([]Slot, error) {
	day, err := time.Parse("2006-01-02", date)
	if err != nil {
		return nil, err
	}
	return s.repo.ListSlots(ctx, facilityID, day, duration)
}
