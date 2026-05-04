package availability

import "time"

type Slot struct {
	StartTime   time.Time `json:"start_time"`
	EndTime     time.Time `json:"end_time"`
	IsAvailable bool      `json:"is_available"`
	Status     string    `json:"status"`
}
