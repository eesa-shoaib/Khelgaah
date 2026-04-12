package availability

import (
	"context"
	"errors"
	"testing"
	"time"
)

type availabilityRepoStub struct{}

func (availabilityRepoStub) ListSlots(_ context.Context, _ int64, _ time.Time, _ int) ([]Slot, error) {
	return nil, nil
}

func (availabilityRepoStub) HasConflict(_ context.Context, _ Querier, _ int64, _, _ time.Time) (bool, error) {
	return false, nil
}

func TestListSlotsRejectsInvalidInput(t *testing.T) {
	service := NewService(availabilityRepoStub{})

	tests := []struct {
		facilityID int64
		date       string
		duration   int
	}{
		{facilityID: 0, date: "2026-03-24", duration: 60},
		{facilityID: 1, date: "2026-03-24", duration: 0},
		{facilityID: 1, date: "24-03-2026", duration: 60},
	}

	for _, testCase := range tests {
		_, err := service.ListSlots(context.Background(), testCase.facilityID, testCase.date, testCase.duration)
		if !errors.Is(err, ErrInvalidAvailabilityRequest) {
			t.Fatalf("expected ErrInvalidAvailabilityRequest for %+v, got %v", testCase, err)
		}
	}
}
