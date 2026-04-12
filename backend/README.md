# Khelgaah Backend

Modular Go backend for the Flutter frontend. It exposes the initial player-facing APIs for auth, venue discovery, facility search, availability lookup, and booking creation.

If you want to understand how to design and build this backend yourself, read:

- `../docs/backend-build-from-scratch.md`
- `../docs/backend-design.md`

## Structure

```text
backend/
  cmd/api                 # application entrypoint
  internal/auth           # signup/login and token issuing
  internal/users          # authenticated user profile
  internal/venues         # map/discovery data
  internal/facilities     # search and facility listing
  internal/availability   # slot generation and availability checks
  internal/bookings       # transactional booking flow
  internal/platform       # shared infra: config, db, middleware, http helpers
  migrations              # PostgreSQL schema
```

## Environment

Set these environment variables before starting the API:

```bash
export DATABASE_URL="postgres://postgres:postgres@localhost:5432/khelgaah?sslmode=disable"
export AUTH_SECRET="replace-this"
export HTTP_ADDR=":8080"
```

There is also a sample file at:

```text
backend/.env.example
```

## Run

Apply the SQL in `migrations/001_init.sql`, then start the server:

```bash
go run ./cmd/api
```

## Initial API

- `POST /api/v1/auth/signup`
- `POST /api/v1/auth/login`
- `GET /api/v1/me`
- `GET /api/v1/venues`
- `GET /api/v1/facilities?q=badminton`
- `GET /api/v1/facilities/{facilityID}/availability?date=2026-03-24&duration=60`
- `GET /api/v1/bookings`
- `POST /api/v1/bookings`
