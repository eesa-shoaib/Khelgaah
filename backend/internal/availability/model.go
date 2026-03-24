package availability

import "time"

type Slot struct {
	StartTime   time.Time `json:"start_time"`
	EndTime     time.Time `json:"end_time"`
	IsAvailable bool      `json:"is_available"`
}

type SlotRequest struct {
	Date       string
	Duration   int
	FacilityID int64
}
