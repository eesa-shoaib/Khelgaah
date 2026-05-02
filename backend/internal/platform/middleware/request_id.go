package middleware

import (
	"context"
	"net/http"
	"time"
)

type contextKey string

const userContextKey contextKey = "user"
const currentUserContextKey contextKey = "current_user"

type CurrentUser struct {
	ID     int64
	Role   string
	Status string
}

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

func WithCurrentUser(r *http.Request, user CurrentUser) *http.Request {
	ctx := context.WithValue(r.Context(), currentUserContextKey, user)
	ctx = context.WithValue(ctx, userContextKey, user.ID)
	return r.WithContext(ctx)
}

func UserIDFromContext(ctx context.Context) (int64, bool) {
	value := ctx.Value(userContextKey)
	userID, ok := value.(int64)
	return userID, ok
}

func CurrentUserFromContext(ctx context.Context) (CurrentUser, bool) {
	value := ctx.Value(currentUserContextKey)
	user, ok := value.(CurrentUser)
	return user, ok
}
