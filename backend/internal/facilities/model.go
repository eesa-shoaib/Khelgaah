package facilities

type Facility struct {
	ID           int64  `json:"id"`
	VenueID      int64  `json:"venue_id"`
	Name         string `json:"name"`
	Sport        string `json:"sport"`
	Type         string `json:"type"`
	OpenSummary  string `json:"open_summary"`
	PricePerHour string `json:"price_per_hour"`
	Status       string `json:"status"`
}
