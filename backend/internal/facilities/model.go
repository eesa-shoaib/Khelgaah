package facilities

type Facility struct {
	ID              int64  `json:"id"`
	VenueID         int64  `json:"venue_id"`
	VenueName       string `json:"venue_name,omitempty"`
	VenueCity       string `json:"venue_city,omitempty"`
	Name            string `json:"name"`
	Sport           string `json:"sport"`
	Type            string `json:"type"`
	OpenSummary     string `json:"open_summary"`
	PricePerHour    string `json:"price_per_hour"`
	OpenTime        string `json:"open_time,omitempty"`
	CloseTime       string `json:"close_time,omitempty"`
	SlotDurationMins int    `json:"slot_duration_mins,omitempty"`
	Status          string `json:"status"`
}
