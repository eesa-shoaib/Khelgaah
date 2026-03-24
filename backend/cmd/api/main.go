package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os/signal"
	"syscall"

	"github.com/eesa/khelgaah/backend/internal/auth"
	"github.com/eesa/khelgaah/backend/internal/availability"
	"github.com/eesa/khelgaah/backend/internal/bookings"
	"github.com/eesa/khelgaah/backend/internal/facilities"
	"github.com/eesa/khelgaah/backend/internal/platform/config"
	"github.com/eesa/khelgaah/backend/internal/platform/db"
	"github.com/eesa/khelgaah/backend/internal/platform/logger"
	"github.com/eesa/khelgaah/backend/internal/platform/middleware"
	"github.com/eesa/khelgaah/backend/internal/users"
	"github.com/eesa/khelgaah/backend/internal/venues"
)

func main() {
	cfg := config.Load()
	logr := logger.New(cfg.AppEnv)

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	pool, err := db.NewPostgresPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("connect database: %v", err)
	}
	defer pool.Close()

	authRepo := auth.NewRepository(pool)
	userRepo := users.NewRepository(pool)
	venueRepo := venues.NewRepository(pool)
	facilityRepo := facilities.NewRepository(pool)
	availabilityRepo := availability.NewRepository(pool)
	bookingRepo := bookings.NewRepository(pool)

	tokenManager := auth.NewTokenManager(cfg.AuthSecret)

	authService := auth.NewService(authRepo, tokenManager)
	venueService := venues.NewService(venueRepo)
	facilityService := facilities.NewService(facilityRepo)
	availabilityService := availability.NewService(availabilityRepo)
	bookingService := bookings.NewService(pool, bookingRepo, availabilityRepo)
	userService := users.NewService(userRepo)

	router := http.NewServeMux()

	router.Handle("GET /healthz", middleware.Chain(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			_, _ = w.Write([]byte(`{"status":"ok"}`))
		}),
		middleware.RequestID,
		middleware.Recover(logr),
	))

	authHandler := auth.NewHandler(authService, tokenManager)
	authHandler.RegisterRoutes(router, logr)

	protected := middleware.ChainMux(router,
		middleware.RequestID,
		middleware.Recover(logr),
	)

	authMiddleware := middleware.Authenticate(tokenManager)

	venues.NewHandler(venueService).RegisterRoutes(router, logr)
	facilities.NewHandler(facilityService).RegisterRoutes(router, logr)
	availability.NewHandler(availabilityService).RegisterRoutes(router, logr)
	bookings.NewHandler(bookingService).RegisterRoutes(router, logr, authMiddleware)
	users.NewHandler(userService).RegisterRoutes(router, logr, authMiddleware)

	server := &http.Server{
		Addr:         cfg.HTTPAddr,
		Handler:      protected,
		ReadTimeout:  cfg.ReadTimeout,
		WriteTimeout: cfg.WriteTimeout,
		IdleTimeout:  cfg.IdleTimeout,
	}

	logr.Info("server starting", "addr", cfg.HTTPAddr, "env", cfg.AppEnv)

	errCh := make(chan error, 1)
	go func() {
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
	}()

	select {
	case <-ctx.Done():
		logr.Info("shutdown signal received")
	case err := <-errCh:
		logr.Error("server failed", "error", err)
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		logr.Error("server shutdown failed", "error", err)
	}
}
