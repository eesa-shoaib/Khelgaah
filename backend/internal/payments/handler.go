package payments

import (
	"errors"
	"net/http"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
	"github.com/eesa/khelgaah/backend/internal/platform/middleware"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) RegisterAdminRoutes(mux *http.ServeMux, authMiddleware, adminOnly middleware.Middleware) {
	protected := func(handler http.HandlerFunc) http.Handler {
		return authMiddleware(adminOnly(handler))
	}

	mux.Handle("GET /api/v1/admin/payments", protected(func(w http.ResponseWriter, r *http.Request) {
		items, err := h.service.List(r.Context(), ListFilter{
			Status: r.URL.Query().Get("status"),
		})
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list payments")
			return
		}

		httpx.WriteJSON(w, http.StatusOK, map[string]any{"payments": items})
	}))

	mux.Handle("POST /api/v1/admin/payments/{bookingID}/refund", protected(func(w http.ResponseWriter, r *http.Request) {
		bookingID, err := httpx.ParseID(r, "bookingID")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid booking id")
			return
		}

		var input RefundInput
		if r.ContentLength > 0 {
			if err := httpx.DecodeJSON(r, &input); err != nil {
				httpx.WriteError(w, http.StatusBadRequest, err.Error())
				return
			}
		}

		payment, err := h.service.RefundByBooking(r.Context(), bookingID, input)
		if err != nil {
			if errors.Is(err, ErrInvalidRefund) {
				httpx.WriteError(w, http.StatusBadRequest, err.Error())
				return
			}
			if errors.Is(err, ErrPaymentNotFound) {
				httpx.WriteError(w, http.StatusNotFound, err.Error())
				return
			}
			httpx.WriteError(w, http.StatusInternalServerError, "failed to process refund")
			return
		}

		httpx.WriteJSON(w, http.StatusOK, payment)
	}))
}
