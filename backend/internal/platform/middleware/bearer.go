package middleware

import (
	"fmt"
	"strconv"
	"strings"
)

func ExtractBearerToken(header string) (string, error) {
	parts := strings.Fields(header)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return "", fmt.Errorf("invalid authorization header: %s", strconv.Quote(header))
	}
	return parts[1], nil
}
