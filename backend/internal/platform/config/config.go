package config

import (
	"bufio"
	"os"
	"strings"
	"time"
)

func init() {
	loadEnv()
}

func loadEnv() {
	file, err := os.Open(".env")
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			os.Setenv(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
		}
	}
	_ = scanner.Err()
}

type Config struct {
	AppEnv          string
	HTTPAddr        string
	DatabaseURL     string
	AuthSecret      string
	ReadTimeout     time.Duration
	WriteTimeout    time.Duration
	IdleTimeout     time.Duration
	ShutdownTimeout time.Duration
}

func Load() Config {
	return Config{
		AppEnv:          envOrDefault("APP_ENV", "development"),
		HTTPAddr:        envOrDefault("HTTP_ADDR", ":8080"),
		DatabaseURL:     envOrDefault("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/khelgaah?sslmode=disable"),
		AuthSecret:      envOrDefault("AUTH_SECRET", "change-me-in-production"),
		ReadTimeout:     5 * time.Second,
		WriteTimeout:    10 * time.Second,
		IdleTimeout:     30 * time.Second,
		ShutdownTimeout: 10 * time.Second,
	}
}

func envOrDefault(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
