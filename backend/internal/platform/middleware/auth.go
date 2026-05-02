package middleware

import (
	"context"
	"net/http"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
)

type TokenParser interface {
	Parse(token string) (int64, error)
}

type UserLoader interface {
	FindByID(rctx context.Context, id int64) (UserAuthRecord, error)
}

type UserAuthRecord struct {
	ID     int64
	Role   string
	Status string
}

func Authenticate(tokenManager TokenParser, userLoader UserLoader) Middleware {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			token, err := ExtractBearerToken(r.Header.Get("Authorization"))
			if err != nil {
				httpx.WriteError(w, http.StatusUnauthorized, "missing or invalid bearer token")
				return
			}

			userID, err := tokenManager.Parse(token)
			if err != nil {
				httpx.WriteError(w, http.StatusUnauthorized, "invalid token")
				return
			}

			user, err := userLoader.FindByID(r.Context(), userID)
			if err != nil {
				httpx.WriteError(w, http.StatusUnauthorized, "user not found")
				return
			}
			if user.Status != "active" {
				httpx.WriteError(w, http.StatusForbidden, "user is not active")
				return
			}

			next.ServeHTTP(w, WithCurrentUser(r, CurrentUser{
				ID:     user.ID,
				Role:   user.Role,
				Status: user.Status,
			}))
		})
	}
}

func RequireRoles(roles ...string) Middleware {
	allowed := make(map[string]struct{}, len(roles))
	for _, role := range roles {
		allowed[role] = struct{}{}
	}

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			user, ok := CurrentUserFromContext(r.Context())
			if !ok {
				httpx.WriteError(w, http.StatusUnauthorized, "missing authenticated user")
				return
			}
			if _, ok := allowed[user.Role]; !ok {
				httpx.WriteError(w, http.StatusForbidden, "insufficient permissions")
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
