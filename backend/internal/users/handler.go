package users

import (
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
	mux.Handle("GET /api/v1/me", authMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userID, ok := middleware.UserIDFromContext(r.Context())
		if !ok {
			httpx.WriteError(w, http.StatusUnauthorized, "missing user")
			return
		}

		me, err := h.service.Me(r.Context(), userID)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "failed to fetch user")
			return
		}

		httpx.WriteJSON(w, http.StatusOK, me)
	})))
}
