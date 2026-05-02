package payments

import (
	"context"
	"errors"
	"fmt"
	"strings"
)

var ErrInvalidRefund = errors.New("invalid refund input")

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) List(ctx context.Context, filter ListFilter) ([]Payment, error) {
	return s.repo.List(ctx, filter)
}

func (s *Service) RefundByBooking(ctx context.Context, bookingID int64, input RefundInput) (Payment, error) {
	if bookingID <= 0 {
		return Payment{}, fmt.Errorf("%w: booking id must be positive", ErrInvalidRefund)
	}

	notes := strings.TrimSpace(input.Notes)
	if notes == "" {
		notes = "Refund processed by admin"
	}

	return s.repo.RefundByBooking(ctx, bookingID, notes)
}

func (s *Service) Analytics(ctx context.Context) (Analytics, error) {
	return s.repo.Analytics(ctx)
}
