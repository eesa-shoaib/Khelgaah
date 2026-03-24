package middleware

import (
	"log/slog"
	"net/http"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
)

func Recover(logr *slog.Logger) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if rec := recover(); rec != nil {
					logr.Error("panic recovered", "panic", rec)
					httpx.WriteError(w, http.StatusInternalServerError, "internal server error")
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}
