package bookings

import (
	"context"
	"errors"
	"testing"
)

func TestCreateRejectsInvalidBookingInput(t *testing.T) {
	service := NewService(nil, nil, nil)

	tests := []CreateBookingInput{
		{FacilityID: 0, StartTime: "2026-03-24T09:00:00Z", EndTime: "2026-03-24T10:00:00Z"},
		{FacilityID: 1, StartTime: "bad", EndTime: "2026-03-24T10:00:00Z"},
		{FacilityID: 1, StartTime: "2026-03-24T10:00:00Z", EndTime: "bad"},
		{FacilityID: 1, StartTime: "2026-03-24T10:00:00Z", EndTime: "2026-03-24T09:00:00Z"},
	}

	for _, input := range tests {
		_, err := service.Create(context.Background(), 99, input)
		if !errors.Is(err, ErrInvalidBooking) {
			t.Fatalf("expected ErrInvalidBooking for %+v, got %v", input, err)
		}
	}
}
