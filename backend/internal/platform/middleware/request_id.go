package middleware

import (
	"context"
	"net/http"
	"time"
)

type contextKey string

const userContextKey contextKey = "user"

func RequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requestID := time.Now().UTC().Format("20060102150405.000000000")
		w.Header().Set("X-Request-ID", requestID)
		next.ServeHTTP(w, r)
	})
}

func WithUser(r *http.Request, userID int64) *http.Request {
	ctx := context.WithValue(r.Context(), userContextKey, userID)
	return r.WithContext(ctx)
}

func UserIDFromContext(ctx context.Context) (int64, bool) {
	value := ctx.Value(userContextKey)
	userID, ok := value.(int64)
	return userID, ok
}
