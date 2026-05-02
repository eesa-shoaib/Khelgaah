package venue_owner

import "time"

type VenueInput struct {
	Name      string  `json:"name"`
	City      string  `json:"city"`
	Address   string  `json:"address"`
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

type Venue struct {
	ID             int64      `json:"id"`
	OwnerUserID    int64      `json:"owner_user_id"`
	Name           string     `json:"name"`
	City           string     `json:"city"`
	Address        string     `json:"address"`
	Latitude       float64    `json:"latitude"`
	Longitude      float64    `json:"longitude"`
	ApprovalStatus string     `json:"approval_status"`
	CreatedAt      time.Time  `json:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at"`
	SuspendedAt    *time.Time `json:"suspended_at,omitempty"`
}

type FacilityInput struct {
	Name         string `json:"name"`
	Sport        string `json:"sport"`
	Type         string `json:"type"`
	OpenSummary  string `json:"open_summary"`
	PricePerHour string `json:"price_per_hour"`
	Status       string `json:"status"`
}

type Facility struct {
	ID           int64     `json:"id"`
	VenueID      int64     `json:"venue_id"`
	Name         string    `json:"name"`
	Sport        string    `json:"sport"`
	Type         string    `json:"type"`
	OpenSummary  string    `json:"open_summary"`
	PricePerHour string    `json:"price_per_hour"`
	Status       string    `json:"status"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type TimeSlotInput struct {
	StartsAt string `json:"starts_at"`
	EndsAt   string `json:"ends_at"`
	SlotType string `json:"slot_type"`
	Reason   string `json:"reason"`
	Status   string `json:"status"`
}

type BlockDatesInput struct {
	StartDate string `json:"start_date"`
	EndDate   string `json:"end_date"`
	Reason    string `json:"reason"`
}

type TimeSlot struct {
	ID              int64     `json:"id"`
	FacilityID      int64     `json:"facility_id"`
	StartsAt        time.Time `json:"starts_at"`
	EndsAt          time.Time `json:"ends_at"`
	SlotType        string    `json:"slot_type"`
	Status          string    `json:"status"`
	Reason          string    `json:"reason"`
	CreatedByUserID *int64    `json:"created_by_user_id,omitempty"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

type Booking struct {
	ID            int64     `json:"id"`
	UserID        int64     `json:"user_id"`
	FacilityID    int64     `json:"facility_id"`
	FacilityName  string    `json:"facility_name"`
	VenueID       int64     `json:"venue_id"`
	VenueName     string    `json:"venue_name"`
	CustomerName  string    `json:"customer_name"`
	CustomerEmail string    `json:"customer_email"`
	StartTime     time.Time `json:"start_time"`
	EndTime       time.Time `json:"end_time"`
	Status        string    `json:"status"`
	Notes         string    `json:"notes"`
	PaymentStatus string    `json:"payment_status"`
	PaymentAmount string    `json:"payment_amount"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type BookingActionInput struct {
	Notes string `json:"notes"`
}

type DashboardStats struct {
	TotalVenues     int64  `json:"total_venues"`
	TotalFacilities int64  `json:"total_facilities"`
	TotalBookings   int64  `json:"total_bookings"`
	Revenue         string `json:"revenue"`
	OccupancyRate   string `json:"occupancy_rate"`
}

type AnalyticsPoint struct {
	Day      string `json:"day"`
	Bookings int64  `json:"bookings"`
	Revenue  string `json:"revenue"`
}
