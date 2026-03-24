package auth

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
)

type Handler struct {
	service      *Service
	tokenManager *TokenManager
}

func NewHandler(service *Service, tokenManager *TokenManager) *Handler {
	return &Handler{service: service, tokenManager: tokenManager}
}

func (h *Handler) RegisterRoutes(mux *http.ServeMux, logr *slog.Logger) {
	mux.HandleFunc("POST /api/v1/auth/signup", func(w http.ResponseWriter, r *http.Request) {
		var input SignupInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}

		result, err := h.service.Signup(r.Context(), input)
		if err != nil {
			logr.Error("signup failed", "error", err)
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}

		httpx.WriteJSON(w, http.StatusCreated, result)
	})

	mux.HandleFunc("POST /api/v1/auth/login", func(w http.ResponseWriter, r *http.Request) {
		var input LoginInput
		if err := httpx.DecodeJSON(r, &input); err != nil {
			httpx.WriteError(w, http.StatusBadRequest, err.Error())
			return
		}

		result, err := h.service.Login(r.Context(), input)
		if err != nil {
			if errors.Is(err, ErrInvalidCredentials) {
				httpx.WriteError(w, http.StatusUnauthorized, err.Error())
				return
			}
			logr.Error("login failed", "error", err)
			httpx.WriteError(w, http.StatusInternalServerError, "failed to login")
			return
		}

		httpx.WriteJSON(w, http.StatusOK, result)
	})
}
