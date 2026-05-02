package venues

type Venue struct {
	ID             int64   `json:"id"`
	OwnerUserID    *int64  `json:"owner_user_id,omitempty"`
	Name           string  `json:"name"`
	City           string  `json:"city"`
	Address        string  `json:"address"`
	Latitude       float64 `json:"latitude"`
	Longitude      float64 `json:"longitude"`
	ApprovalStatus string  `json:"approval_status"`
}
