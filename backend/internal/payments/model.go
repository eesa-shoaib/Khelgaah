package payments

import "time"

type Payment struct {
	ID                int64      `json:"id"`
	BookingID         int64      `json:"booking_id"`
	Amount            string     `json:"amount"`
	Currency          string     `json:"currency"`
	Method            string     `json:"method"`
	Status            string     `json:"status"`
	ProviderReference string     `json:"provider_reference"`
	Notes             string     `json:"notes"`
	PaidAt            *time.Time `json:"paid_at,omitempty"`
	RefundedAt        *time.Time `json:"refunded_at,omitempty"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
}

type ListFilter struct {
	Status string
}

type RefundInput struct {
	Notes string `json:"notes"`
}

type Analytics struct {
	TotalTransactions int64  `json:"total_transactions"`
	TotalPaidAmount   string `json:"total_paid_amount"`
	TotalRefunded     string `json:"total_refunded_amount"`
	PendingCount      int64  `json:"pending_count"`
}
