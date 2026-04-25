# How This Backend Is Made In Go

This backend is built in Go as a simple modular monolith.

That means:

- one Go application runs the API
- code is split by feature
- PostgreSQL stores the data
- HTTP handlers return JSON

The goal is to keep the backend easy to read and easy to grow.

## 1. Main Idea

A request comes in like this:

`client -> route -> handler -> service -> repository -> database`

Each layer does one job:

- `handler`: reads HTTP request and writes HTTP response
- `service`: contains business rules
- `repository`: talks to PostgreSQL

This keeps the code clean. SQL does not leak into handlers, and HTTP details do not leak into business logic.

## 2. Project Structure

The backend lives in `backend/`.

Important folders:

- `backend/cmd/api`: app entrypoint
- `backend/internal/auth`: signup and login
- `backend/internal/users`: current user profile
- `backend/internal/venues`: venue data
- `backend/internal/facilities`: facility listing and search
- `backend/internal/availability`: slot lookup
- `backend/internal/bookings`: booking creation and history
- `backend/internal/platform`: shared code like config, db, middleware, logger, and JSON helpers
- `backend/migrations`: SQL schema

## 3. App Startup

The app starts in `backend/cmd/api/main.go`.

This file does the wiring:

- load config from environment
- connect to PostgreSQL
- create repositories
- create services
- create handlers
- register routes
- start the HTTP server

This file should assemble the app, not hold business logic.

## 4. Config In Go

Configuration is loaded in `backend/internal/platform/config/config.go`.

It reads values like:

- `DATABASE_URL`
- `AUTH_SECRET`
- `HTTP_ADDR`

This is a common Go pattern: keep runtime settings in environment variables and load them once at startup.

## 5. Shared Platform Code

Shared code lives in `backend/internal/platform`.

Main parts:

- `db`: opens the PostgreSQL connection pool
- `logger`: creates structured logs
- `httpx`: helper functions for JSON request/response handling
- `middleware`: request ID, panic recovery, bearer token auth

This prevents repeating the same code in every feature module.

## 6. Feature Modules

Each backend feature follows nearly the same shape:

- `model.go`
- `handler.go`
- `service.go`
- `repository.go`

Simple meaning:

- `model.go`: request/response and domain structs
- `handler.go`: API endpoints
- `service.go`: validation and business logic
- `repository.go`: SQL queries

This is the core pattern used in Go here.

## 7. Example Request Flow

Take login as an example:

1. `POST /api/v1/auth/login` hits the auth handler.
2. The handler decodes JSON.
3. The handler calls the auth service.
4. The service checks the user, compares password hash, and creates a token.
5. The handler returns JSON to the client.

Booking creation follows the same flow, but with more business rules.

## 8. Where Business Logic Goes

Business rules belong in services.

Examples:

- signup validation
- password length checks
- email normalization
- booking time validation
- double-booking prevention

This is important. If you place business rules in handlers, the code becomes hard to test and hard to reuse.

## 9. How Database Access Works

Repositories handle database work.

They should:

- run SQL queries
- map rows into Go structs
- return clean values back to services

They should not:

- decide product rules
- build HTTP responses

PostgreSQL is the source of truth, especially for bookings.

## 10. How Auth Works

Auth is kept simple:

- signup stores a hashed password
- login checks the password hash
- a signed bearer token is issued
- protected routes read the token through middleware

This is enough for an MVP backend without adding a full auth platform.

## 11. How Booking Safety Works

The booking module is the most important part.

To avoid double booking:

- validate the time range
- start a database transaction
- check whether the slot conflicts with an existing booking
- create the booking only if the slot is still free
- commit the transaction

This is the right idea for booking systems: correctness first.

## 12. How JSON Is Handled

The backend uses helper functions in `httpx`.

They do things like:

- decode request JSON
- write JSON responses
- write JSON error responses

That keeps handlers short and consistent.

## 13. How To Add A New API In Go

Use the same pattern already in the repo:

1. Create or update structs in `model.go`.
2. Add the route in `handler.go`.
3. Put validation and business rules in `service.go`.
4. Put SQL in `repository.go`.
5. Wire the module in `cmd/api/main.go`.
6. Add tests.

If the endpoint needs auth, wrap it with auth middleware.

## 14. How To Run It

Basic local steps:

1. Create PostgreSQL database.
2. Apply `backend/migrations/001_init.sql`.
3. Set:
   `DATABASE_URL`, `AUTH_SECRET`, `HTTP_ADDR`
4. Run:
   `go run ./cmd/api`

## 15. Simple Rule To Remember

When building a backend in Go like this:

- keep `main.go` for wiring
- keep handlers thin
- keep services for rules
- keep repositories for SQL
- keep shared code in platform packages

That is the main idea behind how this backend is made.
