package admin

import (
	"context"
	"errors"
	"fmt"
	"strings"
)

var ErrInvalidInput = errors.New("invalid admin input")

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) ListUsers(ctx context.Context, role, status string) ([]User, error) {
	return s.repo.ListUsers(ctx, role, status)
}

func (s *Service) GetUser(ctx context.Context, userID int64) (User, error) {
	if userID <= 0 {
		return User{}, fmt.Errorf("%w: user id must be positive", ErrInvalidInput)
	}
	return s.repo.GetUser(ctx, userID)
}

func (s *Service) ChangeUserRole(ctx context.Context, userID int64, input ChangeRoleInput) (User, error) {
	role := strings.TrimSpace(strings.ToLower(input.Role))
	switch role {
	case "customer", "venue_owner", "admin":
	default:
		return User{}, fmt.Errorf("%w: unsupported role", ErrInvalidInput)
	}
	return s.repo.ChangeUserRole(ctx, userID, role)
}

func (s *Service) SuspendUser(ctx context.Context, userID int64) (User, error) {
	return s.repo.SuspendUser(ctx, userID)
}

func (s *Service) DeleteUser(ctx context.Context, userID int64) error {
	return s.repo.DeleteUser(ctx, userID)
}

func (s *Service) ListVenues(ctx context.Context, status string) ([]Venue, error) {
	return s.repo.ListVenues(ctx, status)
}

func (s *Service) ApproveVenue(ctx context.Context, venueID int64) (Venue, error) {
	return s.repo.UpdateVenueStatus(ctx, venueID, "approved")
}

func (s *Service) RejectVenue(ctx context.Context, venueID int64) (Venue, error) {
	return s.repo.UpdateVenueStatus(ctx, venueID, "rejected")
}

func (s *Service) SuspendVenue(ctx context.Context, venueID int64) (Venue, error) {
	return s.repo.UpdateVenueStatus(ctx, venueID, "suspended")
}

func (s *Service) ListBookings(ctx context.Context, status string) ([]Booking, error) {
	return s.repo.ListBookings(ctx, status)
}

func (s *Service) CancelBooking(ctx context.Context, bookingID int64, notes string) (Booking, error) {
	if bookingID <= 0 {
		return Booking{}, fmt.Errorf("%w: booking id must be positive", ErrInvalidInput)
	}
	if strings.TrimSpace(notes) == "" {
		notes = "Cancelled by admin"
	}
	return s.repo.CancelBooking(ctx, bookingID, notes)
}

func (s *Service) ResolveDispute(ctx context.Context, bookingID int64, input ResolveDisputeInput) (Booking, error) {
	if bookingID <= 0 {
		return Booking{}, fmt.Errorf("%w: booking id must be positive", ErrInvalidInput)
	}
	if input.BookingStatus != "" {
		status := strings.TrimSpace(strings.ToLower(input.BookingStatus))
		switch status {
		case "confirmed", "cancelled", "completed", "rejected", "disputed", "pending":
			input.BookingStatus = status
		default:
			return Booking{}, fmt.Errorf("%w: unsupported booking status", ErrInvalidInput)
		}
	}
	return s.repo.ResolveDispute(ctx, bookingID, input)
}

func (s *Service) Dashboard(ctx context.Context) (DashboardStats, error) {
	return s.repo.Dashboard(ctx)
}

func (s *Service) Analytics(ctx context.Context) (Analytics, error) {
	return s.repo.Analytics(ctx)
}
