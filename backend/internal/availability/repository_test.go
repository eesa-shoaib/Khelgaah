package availability

import (
	"testing"
	"time"
)

func TestGenerateSlotsFromWindowsExpandsOwnerSlots(t *testing.T) {
	baseDay := time.Date(2026, 5, 10, 0, 0, 0, 0, time.UTC)
	windows := []timeWindow{
		{
			start: baseDay.Add(9 * time.Hour),
			end:   baseDay.Add(12 * time.Hour),
		},
	}

	slots := generateSlotsFromWindows(windows, nil, 60)

	if len(slots) != 3 {
		t.Fatalf("expected 3 slots, got %d", len(slots))
	}
	if !slots[0].IsAvailable || slots[0].Status != "available" {
		t.Fatalf("expected first slot to be available, got %#v", slots[0])
	}
	if slots[0].StartTime != baseDay.Add(9*time.Hour) {
		t.Fatalf("unexpected first slot start: %s", slots[0].StartTime)
	}
	if slots[2].EndTime != baseDay.Add(12*time.Hour) {
		t.Fatalf("unexpected last slot end: %s", slots[2].EndTime)
	}
}

func TestGenerateSlotsFromWindowsMarksConflicts(t *testing.T) {
	baseDay := time.Date(2026, 5, 10, 0, 0, 0, 0, time.UTC)
	windows := []timeWindow{
		{
			start: baseDay.Add(9 * time.Hour),
			end:   baseDay.Add(11 * time.Hour),
		},
	}
	blocked := []timeWindow{
		{
			start: baseDay.Add(10 * time.Hour),
			end:   baseDay.Add(11 * time.Hour),
		},
	}

	slots := generateSlotsFromWindows(windows, blocked, 60)

	if len(slots) != 2 {
		t.Fatalf("expected 2 slots, got %d", len(slots))
	}
	if !slots[0].IsAvailable {
		t.Fatalf("expected first slot to be available, got %#v", slots[0])
	}
	if slots[1].IsAvailable || slots[1].Status != "blocked" {
		t.Fatalf("expected second slot to be blocked, got %#v", slots[1])
	}
}
