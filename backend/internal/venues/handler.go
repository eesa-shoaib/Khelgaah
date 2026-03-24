package venues

import (
	"log/slog"
	"net/http"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux, _ *slog.Logger) {
	mux.HandleFunc("GET /api/v1/venues", func(w http.ResponseWriter, r *http.Request) {
		venues, err := h.service.List(r.Context())
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to list venues")
			return
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]any{"venues": venues})
	})
}
