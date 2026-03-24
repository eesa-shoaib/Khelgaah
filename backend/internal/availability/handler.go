package availability

import (
	"log/slog"
	"net/http"
	"strconv"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux, _ *slog.Logger) {
	mux.HandleFunc("GET /api/v1/facilities/{facilityID}/availability", func(w http.ResponseWriter, r *http.Request) {
		facilityID, err := strconv.ParseInt(r.PathValue("facilityID"), 10, 64)
		if err != nil {
			httpx.WriteError(w, http.StatusBadRequest, "invalid facility id")
			return
		}

		duration, err := strconv.Atoi(r.URL.Query().Get("duration"))
		if err != nil || duration <= 0 {
			httpx.WriteError(w, http.StatusBadRequest, "invalid duration")
			return
		}

		date := r.URL.Query().Get("date")
		if date == "" {
			httpx.WriteError(w, http.StatusBadRequest, "date is required")
			return
		}

		slots, err := h.service.ListSlots(r.Context(), facilityID, date, duration)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to load availability")
			return
		}

		httpx.WriteJSON(w, http.StatusOK, map[string]any{"slots": slots})
	})
}
