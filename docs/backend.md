# Khelgaah Backend Documentation

## Overview
Modular Go backend for the Khelgaah sports venue booking platform. Uses a repository pattern with raw SQL and PostgreSQL.

## Tech Stack
- **Language:** Go 1.26
- **Database:** PostgreSQL (pgx/v5)
- **Framework:** Net/HTTP (Standard library)
- **Architecture:** Modular Monolith / Repository Pattern

## Directory Structure
- `cmd/api`: Application entrypoint (`main.go`).
- `internal/auth`: Signup, login, and JWT token management.
- `internal/users`: User profile management.
- `internal/venues`: Venue discovery and listing.
- `internal/facilities`: Facility search and listing.
- `internal/availability`: Time slot generation and availability checks.
- `internal/bookings`: Transactional booking flow.
- `internal/payments`: Payment processing and history.
- `internal/venue_owner`: Venue owner specific dashboard and management.
- `internal/admin`: Platform-wide administration and analytics.
- `internal/platform`: Shared infrastructure (config, db, logger, middleware, http helpers).
- `migrations`: PostgreSQL schema migrations.

## Key APIs
- **Public:** Auth (Signup/Login), Venue/Facility Discovery, Availability Checks.
- **Customer:** Profile management, Booking creation, Booking history.
- **Venue Owner:** Dashboard, Venue/Facility management, Time slot management, Booking approval.
- **Admin:** System dashboard, User management, Venue approval, Global booking/payment oversight.

## Setup & Run
1. **Environment Variables:**
   ```bash
   export DATABASE_URL="postgres://postgres:postgres@localhost:5432/khelgaah?sslmode=disable"
   export AUTH_SECRET="your-secret-here"
   export HTTP_ADDR=":8080"
   ```
2. **Migrations:** Apply SQL in `backend/migrations/`.
3. **Run:** `go run ./cmd/api` from `backend/` directory.
