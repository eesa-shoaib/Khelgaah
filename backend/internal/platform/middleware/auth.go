package middleware

import (
	"net/http"

	"github.com/eesa/khelgaah/backend/internal/platform/httpx"
)

type TokenParser interface {
	Parse(token string) (int64, error)
}

func Authenticate(tokenManager TokenParser) Middleware {
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

			next.ServeHTTP(w, WithUser(r, userID))
		})
	}
}
