package venue_owner

import (
	"context"
	"errors"
	"net/http"
	"strconv"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
	"github.com/eesa/khelgaah/backend/internal/platform/middleware"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux, authMiddleware, ownerOnly middleware.Middleware) {
	protected := func(handler http.HandlerFunc) http.Handler {
		return authMiddleware(ownerOnly(handler))
	}

	mux.Handle("POST /api/v1/venue-owner/venues", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		var input VenueInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}

		item, err := h.service.CreateVenue(r.Context(), user.ID, input)
		writeOwnerResult(w, item, err, "failed to create venue")
	}))

	mux.Handle("GET /api/v1/venue-owner/venues", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		items, err := h.service.ListVenues(r.Context(), user.ID)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list venues")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"venues": items})
	}))

	mux.Handle("GET /api/v1/venue-owner/venues/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		venueID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid venue id")
			return
		}
		item, err := h.service.GetVenue(r.Context(), user.ID, venueID)
		writeOwnerResult(w, item, err, "failed to get venue")
	}))

	mux.Handle("PUT /api/v1/venue-owner/venues/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		venueID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid venue id")
			return
		}
		var input VenueInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.UpdateVenue(r.Context(), user.ID, venueID, input)
		writeOwnerResult(w, item, err, "failed to update venue")
	}))

	mux.Handle("DELETE /api/v1/venue-owner/venues/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		venueID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid venue id")
			return
		}
		err = h.service.DeleteVenue(r.Context(), user.ID, venueID)
		writeOwnerDelete(w, err, "failed to delete venue")
	}))

	mux.Handle("POST /api/v1/venue-owner/venues/{venueID}/facilities", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		venueID, err := httpx.ParseID(r, "venueID")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid venue id")
			return
		}
		var input FacilityInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.CreateFacility(r.Context(), user.ID, venueID, input)
		writeOwnerResult(w, item, err, "failed to create facility")
	}))

	mux.Handle("GET /api/v1/venue-owner/venues/{venueID}/facilities", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		venueID, err := httpx.ParseID(r, "venueID")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid venue id")
			return
		}
		items, err := h.service.ListFacilities(r.Context(), user.ID, venueID)
		if err != nil {
			writeOwnerError(w, err, "failed to list facilities")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"facilities": items})
	}))

	mux.Handle("PUT /api/v1/venue-owner/facilities/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		facilityID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid facility id")
			return
		}
		var input FacilityInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.UpdateFacility(r.Context(), user.ID, facilityID, input)
		writeOwnerResult(w, item, err, "failed to update facility")
	}))

	mux.Handle("DELETE /api/v1/venue-owner/facilities/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		facilityID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid facility id")
			return
		}
		err = h.service.DeleteFacility(r.Context(), user.ID, facilityID)
		writeOwnerDelete(w, err, "failed to delete facility")
	}))

	mux.Handle("POST /api/v1/venue-owner/facilities/{id}/time-slots", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		facilityID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid facility id")
			return
		}
		var input TimeSlotInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.CreateTimeSlot(r.Context(), user.ID, facilityID, input)
		writeOwnerResult(w, item, err, "failed to create time slot")
	}))

	mux.Handle("GET /api/v1/venue-owner/facilities/{id}/availability", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		facilityID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid facility id")
			return
		}
		items, err := h.service.ListAvailability(
			r.Context(),
			user.ID,
			facilityID,
			r.URL.Query().Get("from"),
			r.URL.Query().Get("to"),
		)
		if err != nil {
			writeOwnerError(w, err, "failed to list availability")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"time_slots": items})
	}))

	mux.Handle("PUT /api/v1/venue-owner/time-slots/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		slotID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid time slot id")
			return
		}
		var input TimeSlotInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		item, err := h.service.UpdateTimeSlot(r.Context(), user.ID, slotID, input)
		writeOwnerResult(w, item, err, "failed to update time slot")
	}))

	mux.Handle("POST /api/v1/venue-owner/facilities/{id}/block-dates", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		facilityID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid facility id")
			return
		}
		var input BlockDatesInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}
		items, err := h.service.BlockDates(r.Context(), user.ID, facilityID, input)
		if err != nil {
			writeOwnerError(w, err, "failed to block dates")
			return
		}
		httpx.WriteJSON(w, http.StatusCreated, map[string]any{"time_slots": items})
	}))

	mux.Handle("GET /api/v1/venue-owner/bookings", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		items, err := h.service.ListBookings(r.Context(), user.ID, r.URL.Query().Get("status"))
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list bookings")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"bookings": items})
	}))

	mux.Handle("GET /api/v1/venue-owner/bookings/{id}", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		bookingID, err := httpx.ParseID(r, "id")
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid booking id")
			return
		}
		item, err := h.service.GetBooking(r.Context(), user.ID, bookingID)
		writeOwnerResult(w, item, err, "failed to get booking")
	}))

	actionHandler := func(action func(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error), defaultError string) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			user, _ := middleware.CurrentUserFromContext(r.Context())
			bookingID, err := httpx.ParseID(r, "id")
			if err != nil {
				httpx.WriteError(w, http.StatusBadRequest, "invalid booking id")
				return
			}
			var input BookingActionInput
			if r.ContentLength > 0 {
				if err := httpx.DecodeJSON(r, &input); err != nil {
					httpx.WriteError(w, http.StatusBadRequest, err.Error())
					return
				}
			}
			item, err := action(r.Context(), user.ID, bookingID, input)
			writeOwnerResult(w, item, err, defaultError)
		}
	}

	mux.Handle("PUT /api/v1/venue-owner/bookings/{id}/approve", protected(actionHandler(
		func(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error) {
			return h.service.ApproveBooking(ctx, ownerID, bookingID, input)
		},
		"failed to approve booking",
	)))
	mux.Handle("PUT /api/v1/venue-owner/bookings/{id}/reject", protected(actionHandler(
		func(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error) {
			return h.service.RejectBooking(ctx, ownerID, bookingID, input)
		},
		"failed to reject booking",
	)))
	mux.Handle("PUT /api/v1/venue-owner/bookings/{id}/cancel", protected(actionHandler(
		func(ctx context.Context, ownerID, bookingID int64, input BookingActionInput) (Booking, error) {
			return h.service.CancelBooking(ctx, ownerID, bookingID, input)
		},
		"failed to cancel booking",
	)))

	mux.Handle("GET /api/v1/venue-owner/dashboard", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		stats, err := h.service.Dashboard(r.Context(), user.ID)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to load dashboard")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, stats)
	}))

	mux.Handle("GET /api/v1/venue-owner/analytics", protected(func(w http.ResponseWriter, r *http.Request) {
		user, _ := middleware.CurrentUserFromContext(r.Context())
		days, _ := strconv.Atoi(r.URL.Query().Get("days"))
		items, err := h.service.Analytics(r.Context(), user.ID, days)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to load analytics")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"analytics": items})
	}))
}

func writeOwnerResult[T any](w http.ResponseWriter, item T, err error, fallback string) {
	if err != nil {
		writeOwnerError(w, err, fallback)
		return
	}
	httpx.WriteJSON(w, http.StatusOK, item)
}

func writeOwnerDelete(w http.ResponseWriter, err error, fallback string) {
	if err != nil {
		writeOwnerError(w, err, fallback)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func writeOwnerError(w http.ResponseWriter, err error, fallback string) {
	switch {
	case errors.Is(err, ErrInvalidInput):
		httpx.WriteError(w, http.StatusBadRequest, err.Error())
	case errors.Is(err, ErrNotFound):
		httpx.WriteError(w, http.StatusNotFound, err.Error())
	default:
		httpx.WriteError(w, http.StatusInternalServerError, fallback)
	}
}
