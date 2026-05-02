package bookings

import "time"

type Booking struct {
	ID         int64     `json:"id"`
	UserID     int64     `json:"user_id"`
	FacilityID int64     `json:"facility_id"`
	StartTime  time.Time `json:"start_time"`
	EndTime    time.Time `json:"end_time"`
	Status     string    `json:"status"`
	Notes      string    `json:"notes"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type CreateBookingInput struct {
	FacilityID int64  `json:"facility_id"`
	StartTime  string `json:"start_time"`
	EndTime    string `json:"end_time"`
}
