package admin

import "time"

type User struct {
	ID          int64      `json:"id"`
	FullName    string     `json:"full_name"`
	Email       string     `json:"email"`
	Phone       string     `json:"phone"`
	Role        string     `json:"role"`
	Status      string     `json:"status"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	SuspendedAt *time.Time `json:"suspended_at,omitempty"`
}

type ChangeRoleInput struct {
	Role string `json:"role"`
}

type Venue struct {
	ID             int64      `json:"id"`
	OwnerUserID    *int64     `json:"owner_user_id,omitempty"`
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

type Booking struct {
	ID            int64     `json:"id"`
	UserID        int64     `json:"user_id"`
	FacilityID    int64     `json:"facility_id"`
	UserName      string    `json:"user_name"`
	FacilityName  string    `json:"facility_name"`
	VenueName     string    `json:"venue_name"`
	StartTime     time.Time `json:"start_time"`
	EndTime       time.Time `json:"end_time"`
	Status        string    `json:"status"`
	Notes         string    `json:"notes"`
	PaymentStatus string    `json:"payment_status"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type ResolveDisputeInput struct {
	ResolutionNotes string `json:"resolution_notes"`
	BookingStatus   string `json:"booking_status"`
}

type DashboardStats struct {
	TotalUsers      int64  `json:"total_users"`
	TotalVenues     int64  `json:"total_venues"`
	TotalBookings   int64  `json:"total_bookings"`
	TotalRevenue    string `json:"total_revenue"`
	OpenDisputes    int64  `json:"open_disputes"`
	PendingVenues   int64  `json:"pending_venues"`
	PendingBookings int64  `json:"pending_bookings"`
}

type Analytics struct {
	ActiveCustomers   int64  `json:"active_customers"`
	ActiveOwners      int64  `json:"active_owners"`
	ConfirmedBookings int64  `json:"confirmed_bookings"`
	RefundedAmount    string `json:"refunded_amount"`
}
