package admin

import (
	"context"
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

func (h *Handler) RegisterRoutes(mux *http.ServeMux, authMiddleware, adminOnly middleware.Middleware) {
	protected := func(handler http.HandlerFunc) http.Handler {
		return authMiddleware(adminOnly(handler))
	}

	mux.Handle("GET /api/v1/admin/users", protected(func(w http.ResponseWriter, r *http.Request) {
		items, err := h.service.ListUsers(r.Context(), r.URL.Query().Get("role"), r.URL.Query().Get("status"))
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list users")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"users": items})
	}))

	mux.Handle("GET /api/v1/admin/users/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		userID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid user id")
			return
		}
		item, err := h.service.GetUser(r.Context(), userID)
		writeAdminResult(w, item, err, "failed to get user")
	}))

	mux.Handle("PUT /api/v1/admin/users/{id}/role", protected(func(w http.ResponseWriter, r *http.Request) {
		userID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid user id")
			return
		}
		var input ChangeRoleInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.ChangeUserRole(r.Context(), userID, input)
		writeAdminResult(w, item, err, "failed to update user role")
	}))

	mux.Handle("PUT /api/v1/admin/users/{id}/suspend", protected(func(w http.ResponseWriter, r *http.Request) {
		userID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid user id")
			return
		}
		item, err := h.service.SuspendUser(r.Context(), userID)
		writeAdminResult(w, item, err, "failed to suspend user")
	}))

	mux.Handle("DELETE /api/v1/admin/users/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		userID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid user id")
			return
		}
		err = h.service.DeleteUser(r.Context(), userID)
		if err != nil {
			writeAdminError(w, err, "failed to delete user")
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}))

	mux.Handle("GET /api/v1/admin/venues", protected(func(w http.ResponseWriter, r *http.Request) {
		items, err := h.service.ListVenues(r.Context(), r.URL.Query().Get("status"))
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list venues")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"venues": items})
	}))

	statusAction := func(fn func(context.Context, int64) (Venue, error), fallback string) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			venueID, err := httpx.ParseID(r, "id")
			if err != nil {
				httpx.WriteError(w, http.StatusBadRequest, "invalid venue id")
				return
			}
			item, err := fn(r.Context(), venueID)
			writeAdminResult(w, item, err, fallback)
		}
	}

	mux.Handle("PUT /api/v1/admin/venues/{id}/approve", protected(statusAction(h.service.ApproveVenue, "failed to approve venue")))
	mux.Handle("PUT /api/v1/admin/venues/{id}/reject", protected(statusAction(h.service.RejectVenue, "failed to reject venue")))
	mux.Handle("PUT /api/v1/admin/venues/{id}/suspend", protected(statusAction(h.service.SuspendVenue, "failed to suspend venue")))

	mux.Handle("GET /api/v1/admin/bookings", protected(func(w http.ResponseWriter, r *http.Request) {
		items, err := h.service.ListBookings(r.Context(), r.URL.Query().Get("status"))
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list bookings")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"bookings": items})
	}))

	mux.Handle("PUT /api/v1/admin/bookings/{id}/cancel", protected(func(w http.ResponseWriter, r *http.Request) {
		bookingID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid booking id")
			return
		}
		var input struct {
			Notes string `json:"notes"`
		}
		if r.ContentLength > 0 {
			if err := httpx.DecodeJSON(r, &input); err != nil {
				httpx.WriteError(w, http.StatusBadRequest, err.Error())
				return
			}
		}
		item, err := h.service.CancelBooking(r.Context(), bookingID, input.Notes)
		writeAdminResult(w, item, err, "failed to cancel booking")
	}))

	mux.Handle("PUT /api/v1/admin/bookings/{id}/resolve", protected(func(w http.ResponseWriter, r *http.Request) {
		bookingID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid booking id")
			return
		}
		var input ResolveDisputeInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.ResolveDispute(r.Context(), bookingID, input)
		writeAdminResult(w, item, err, "failed to resolve dispute")
	}))

	mux.Handle("GET /api/v1/admin/dashboard", protected(func(w http.ResponseWriter, r *http.Request) {
		stats, err := h.service.Dashboard(r.Context())
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to load dashboard")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, stats)
	}))

	mux.Handle("GET /api/v1/admin/analytics", protected(func(w http.ResponseWriter, r *http.Request) {
		stats, err := h.service.Analytics(r.Context())
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to load analytics")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, stats)
	}))
}

func writeAdminResult[T any](w http.ResponseWriter, item T, err error, fallback string) {
	if err != nil {
		writeAdminError(w, err, fallback)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, item)
}

func writeAdminError(w http.ResponseWriter, err error, fallback string) {
	switch {
	case errors.Is(err, ErrInvalidInput):
		httpx.WriteError(w, http.StatusBadRequest, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.WriteError(w, http.StatusNotFound, err.Error())
	default:
		httpx.WriteError(w, http.StatusInternalServerError, fallback)
	}
}
