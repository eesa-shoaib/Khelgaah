package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"
)

type TokenManager struct {
	secret []byte
}

type tokenPayload struct {
	Sub int64 `json:"sub"`
	Exp int64 `json:"exp"`
}

func NewTokenManager(secret string) *TokenManager {
	return &TokenManager{secret: []byte(secret)}
}

func (tm *TokenManager) Issue(userID int64) (string, error) {
	payload := tokenPayload{
		Sub: userID,
		Exp: time.Now().Add(24 * time.Hour).Unix(),
	}

	rawPayload, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}

	encoded := base64.RawURLEncoding.EncodeToString(rawPayload)
	signature := tm.sign(encoded)
	return fmt.Sprintf("%s.%s", encoded, signature), nil
}

func (tm *TokenManager) Parse(token string) (int64, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 2 {
		return 0, errors.New("invalid token format")
	}

	if !hmac.Equal([]byte(tm.sign(parts[0])), []byte(parts[1])) {
		return 0, errors.New("invalid token signature")
	}

	payloadBytes, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return 0, err
	}

	var payload tokenPayload
	if err := json.Unmarshal(payloadBytes, &payload); err != nil {
		return 0, err
	}

	if time.Now().Unix() > payload.Exp {
		return 0, errors.New("token expired")
	}

	return payload.Sub, nil
}

func (tm *TokenManager) sign(value string) string {
	mac := hmac.New(sha256.New, tm.secret)
	_, _ = mac.Write([]byte(value))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}
