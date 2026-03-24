package bookings

import (
	"errors"
	"log/slog"
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

func (h *Handler) RegisterRoutes(mux *http.ServeMux, _ *slog.Logger, authMiddleware middleware.Middleware) {
	mux.Handle("POST /api/v1/bookings", authMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userID, ok := middleware.UserIDFromContext(r.Context())
		if !ok {
			httpx.WriteError(w, http.StatusUnauthorized, "missing user")
			return
		}

		var input CreateBookingInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}

		booking, err := h.service.Create(r.Context(), userID, input)
		if err != nil {
			if errors.Is(err, ErrSlotUnavailable) {
				httpx.WriteError(w, http.StatusConflict, err.Error())
				return
			}
			httpx.WriteError(w, http.StatusInternalServerError, "failed to create booking")
			return
		}

		httpx.WriteJSON(w, http.StatusCreated, booking)
	})))

	mux.Handle("GET /api/v1/bookings", authMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userID, ok := middleware.UserIDFromContext(r.Context())
		if !ok {
			httpx.WriteError(w, http.StatusUnauthorized, "missing user")
			return
		}

		items, err := h.service.ListByUser(r.Context(), userID)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list bookings")
			return
		}

		httpx.WriteJSON(w, http.StatusOK, map[string]any{"bookings": items})
	})))
}
