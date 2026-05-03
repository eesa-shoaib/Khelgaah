package venue_owner

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"
)

var ErrInvalidInput = errors.New("invalid venue owner input")

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) CreateVenue(ctx context.Context, ownerID int64, input VenueInput) (Venue, error) {
	if strings.TrimSpace(input.Name) == "" {
		return Venue{}, fmt.Errorf("%w: venue name is required", ErrInvalidInput)
	}
	return s.repo.CreateVenue(ctx, ownerID, normalizeVenueInput(input))
}

func (s *Service) ListVenues(ctx context.Context, ownerID int64) ([]Venue, error) {
	return s.repo.ListVenues(ctx, ownerID)
}

func (s *Service) GetVenue(ctx context.Context, ownerID, venueID int64) (Venue, error) {
	return s.repo.GetVenue(ctx, ownerID, venueID)
}

func (s *Service) UpdateVenue(ctx context.Context, ownerID, venueID int64, input VenueInput) (Venue, error) {
	if venueID <= 0 {
		return Venue{}, fmt.Errorf("%w: venue id must be positive", ErrInvalidInput)
	}
	return s.repo.UpdateVenue(ctx, ownerID, venueID, normalizeVenueInput(input))
}

func (s *Service) DeleteVenue(ctx context.Context, ownerID, venueID int64) error {
	if venueID <= 0 {
		return fmt.Errorf("%w: venue id must be positive", ErrInvalidInput)
	}
	return s.repo.DeleteVenue(ctx, ownerID, venueID)
}

func (s *Service) CreateFacility(ctx context.Context, ownerID, venueID int64, input FacilityInput) (Facility, error) {
	if strings.TrimSpace(input.Name) == "" || strings.TrimSpace(input.Sport) == "" {
		return Facility{}, fmt.Errorf("%w: facility name and sport are required", ErrInvalidInput)
	}
	return s.repo.CreateFacility(ctx, ownerID, venueID, normalizeFacilityInput(input))
}

func (s *Service) ListFacilities(ctx context.Context, ownerID, venueID int64) ([]Facility, error) {
	return s.repo.ListFacilities(ctx, ownerID, venueID)
}

func (s *Service) UpdateFacility(ctx context.Context, ownerID, facilityID int64, input FacilityInput) (Facility, error) {
	if facilityID <= 0 {
		return Facility{}, fmt.Errorf("%w: facility id must be positive", ErrInvalidInput)
	}
	return s.repo.UpdateFacility(ctx, ownerID, facilityID, normalizeFacilityInput(input))
}

func (s *Service) DeleteFacility(ctx context.Context, ownerID, facilityID int64) error {
	if facilityID <= 0 {
		return fmt.Errorf("%w: facility id must be positive", ErrInvalidInput)
	}
	return s.repo.DeleteFacility(ctx, ownerID, facilityID)
}

func (s *Service) CreateTimeSlot(ctx context.Context, ownerID, facilityID int64, input TimeSlotInput) (TimeSlot, error) {
	slotInput, err := normalizeTimeSlotInput(input)
	if err != nil {
		return TimeSlot{}, err
	}
	return s.repo.CreateTimeSlot(ctx, ownerID, facilityID, slotInput)
}

func (s *Service) ListAvailability(ctx context.Context, ownerID, facilityID int64, from, to string) ([]TimeSlot, error) {
	fromTime, err := time.Parse(time.RFC3339, from)
	if err != nil {
		return nil, fmt.Errorf("%w: from must be RFC3339", ErrInvalidInput)
	}
	toTime, err := time.Parse(time.RFC3339, to)
	if err != nil {
		return nil, fmt.Errorf("%w: to must be RFC3339", ErrInvalidInput)
	}
	if !toTime.After(fromTime) {
		return nil, fmt.Errorf("%w: to must be after from", ErrInvalidInput)
	}
	return s.repo.ListAvailability(ctx, ownerID, facilityID, fromTime, toTime)
}

func (s *Service) UpdateTimeSlot(ctx context.Context, ownerID, slotID int64, input TimeSlotInput) (TimeSlot, error) {
	slotInput, err := normalizeTimeSlotInput(input)
	if err != nil {
		return TimeSlot{}, err
	}
	return s.repo.UpdateTimeSlot(ctx, ownerID, slotID, slotInput)
}

func (s *Service) DeleteTimeSlot(ctx context.Context, ownerID, slotID int64) error {
	if slotID <= 0 {
		return fmt.Errorf("%w: slot id must be positive", ErrInvalidInput)
	}
	return s.repo.DeleteTimeSlot(ctx, ownerID, slotID)
}

func (s *Service) BlockDates(ctx context.Context, ownerID, facilityID int64, input BlockDatesInput) ([]TimeSlot, error) {
	if _, err := time.Parse("2006-01-02", input.StartDate); err != nil {
		return nil, fmt.Errorf("%w: start_date must use YYYY-MM-DD", ErrInvalidInput)
	}
	if _, err := time.Parse("2006-01-02", input.EndDate); err != nil {
		return nil, fmt.Errorf("%w: end_date must use YYYY-MM-DD", ErrInvalidInput)
	}
	if strings.TrimSpace(input.Reason) == "" {
		input.Reason = "Maintenance block"
	}
	return s.repo.BlockDates(ctx, ownerID, facilityID, input)
}

func (s *Service) ListBookings(ctx context.Context, ownerID int64, status string) ([]Booking, error) {
	return s.repo.ListBookings(ctx, ownerID, status)
}

func (s *Service) GetBooking(ctx context.Context, ownerID, bookingID int64) (Booking, error) {
	return s.repo.GetBooking(ctx, ownerID, bookingID)
}

func (s *Service) ApproveBooking(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error) {
	return s.repo.UpdateBookingStatus(ctx, ownerID, bookingID, "confirmed", strings.TrimSpace(input.Notes))
}

func (s *Service) RejectBooking(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error) {
	return s.repo.UpdateBookingStatus(ctx, ownerID, bookingID, "rejected", strings.TrimSpace(input.Notes))
}

func (s *Service) CancelBooking(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error) {
	return s.repo.UpdateBookingStatus(ctx, ownerID, bookingID, "cancelled", strings.TrimSpace(input.Notes))
}

func (s *Service) Dashboard(ctx context.Context, ownerID int64) (DashboardStats, error) {
	return s.repo.Dashboard(ctx, ownerID)
}

func (s *Service) Analytics(ctx context.Context, ownerID int64, days int) ([]AnalyticsPoint, error) {
	if days <= 0 {
		days = 30
	}
	return s.repo.Analytics(ctx, ownerID, days)
}

func normalizeVenueInput(input VenueInput) VenueInput {
	input.Name = strings.TrimSpace(input.Name)
	input.City = strings.TrimSpace(input.City)
	input.Address = strings.TrimSpace(input.Address)
	return input
}

func normalizeFacilityInput(input FacilityInput) FacilityInput {
	input.Name = strings.TrimSpace(input.Name)
	input.Sport = strings.TrimSpace(input.Sport)
	input.Type = strings.TrimSpace(input.Type)
	input.OpenSummary = strings.TrimSpace(input.OpenSummary)
	if input.PricePerHour == "" {
		input.PricePerHour = "0"
	}
	if input.Status == "" {
		input.Status = "active"
	}
	return input
}

func normalizeTimeSlotInput(input TimeSlotInput) (TimeSlotInput, error) {
	start, err := time.Parse(time.RFC3339, input.StartsAt)
	if err != nil {
		return TimeSlotInput{}, fmt.Errorf("%w: starts_at must be RFC3339", ErrInvalidInput)
	}
	end, err := time.Parse(time.RFC3339, input.EndsAt)
	if err != nil {
		return TimeSlotInput{}, fmt.Errorf("%w: ends_at must be RFC3339", ErrInvalidInput)
	}
	if !end.After(start) {
		return TimeSlotInput{}, fmt.Errorf("%w: ends_at must be after starts_at", ErrInvalidInput)
	}
	input.SlotType = strings.TrimSpace(strings.ToLower(input.SlotType))
	if input.SlotType == "" {
		input.SlotType = "available"
	}
	input.Status = strings.TrimSpace(strings.ToLower(input.Status))
	if input.Status == "" {
		input.Status = "active"
	}
	input.Reason = strings.TrimSpace(input.Reason)
	return input, nil
}
