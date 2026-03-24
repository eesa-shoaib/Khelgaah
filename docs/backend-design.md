# Khelgaah Backend Design

## Start Here

If you are onboarding onto the backend, inspect these in order:

1. `backend/cmd/api/main.go`
2. `backend/internal/bookings`
3. `backend/internal/availability`
4. `backend/internal/auth`
5. `backend/migrations/001_init.sql`

## Purpose

This document explains the backend in depth:

- why the backend is structured the way it is
- what each package does
- how requests flow through the system
- where business logic lives
- how booking consistency is enforced

The backend is implemented in Go and lives in:

```text
backend/
```

It is currently designed as a modular monolith backed by PostgreSQL.

## Current Backend Scope

The backend currently supports the player-facing MVP:

- auth
- current-user profile
- venue listing
- facility listing/search
- availability lookup
- booking creation
- booking history

It does not yet support:

- owner dashboards
- tournaments
- payments
- admin operations
- advanced map queries

## Why a Modular Monolith

At this stage, Khelgaah does not need microservices.

A modular monolith is the right tradeoff because:

- the app is still early
- the domains are closely related
- most requests touch shared concepts like users, facilities, and bookings
- operational complexity should stay low

This design gives strong separation of concerns without introducing distributed-system overhead.

The backend can evolve later into multiple services if there is a real need, but it should not start there.

## Top-Level Structure

The backend structure is:

```text
backend/
  cmd/api
  internal/auth
  internal/users
  internal/venues
  internal/facilities
  internal/availability
  internal/bookings
  internal/platform
  migrations
```

This is a domain-oriented structure.

## How to Read the Backend

Read one domain vertically rather than reading by file type across the whole repo.

For example, for `bookings`:

1. `handler.go`
2. `service.go`
3. `repository.go`
4. `model.go`

Then repeat the same pattern for `availability` and `auth`.

## Composition Root

### `backend/cmd/api/main.go`

This file is the backend entrypoint.

Its responsibilities are:

- load configuration from environment variables
- initialize logging
- connect to PostgreSQL
- construct repositories
- construct services
- construct handlers
- register routes
- start the HTTP server
- handle graceful shutdown

### Why This File Matters

This file is where dependency wiring happens. It is intentionally the place where everything is connected.

It should not contain business rules such as:

- password validation logic
- booking conflict decisions
- SQL queries

Instead, it assembles the modules and starts the process.

## Shared Infrastructure Layer

The shared infrastructure layer lives in:

```text
backend/internal/platform
```

This package contains cross-cutting concerns that are used by multiple domains.

### `config`

Loads runtime configuration such as:

- app environment
- HTTP bind address
- database URL
- auth secret
- timeout settings

The goal is to keep environment-dependent behavior out of business code.

### `db`

Creates the PostgreSQL connection pool using `pgx`.

The DB package should stay small. Its job is to establish connectivity and expose the shared pool object.

### `logger`

Initializes structured logging.

This gives the server a consistent logging format and avoids ad hoc print statements scattered across the codebase.

### `httpx`

Contains small HTTP helpers for:

- decoding JSON requests
- writing JSON responses
- writing JSON error messages

This reduces repetition in handlers and keeps HTTP behavior consistent.

### `middleware`

Provides request-processing wrappers, such as:

- request ID assignment
- panic recovery
- bearer token extraction
- authentication

This is where cross-cutting request logic belongs.

### Important Note About `internal`

The use of Go’s `internal` package structure is intentional. It keeps these packages private to the module and helps enforce architectural boundaries.

## Domain Packages

Each domain package owns a specific business concern.

## `auth`

### Responsibilities

- create users
- authenticate users
- hash passwords
- issue auth tokens
- validate credentials

### Files

- `model.go`
- `handler.go`
- `service.go`
- `repository.go`
- `token.go`

### Layer Breakdown

#### Handler

The auth handler exposes endpoints like:

- `POST /api/v1/auth/signup`
- `POST /api/v1/auth/login`

It parses request bodies and returns JSON.

#### Service

The auth service contains the actual auth rules:

- generate password hash on signup
- look up the user on login
- compare password against stored hash
- issue a signed token

#### Repository

The auth repository reads and writes user auth data to PostgreSQL.

#### Token Manager

The token manager signs and parses the auth token. It is separate from the HTTP handler so token logic stays reusable.

### Why `auth` Is Separate

Authentication is its own domain because it has a distinct set of concerns:

- credential storage
- password verification
- token handling

It should not be mixed directly into unrelated domains like bookings or facilities.

### Current Auth Maturity

The current auth system is intentionally lightweight. It is enough for the MVP request flow, but it is not yet a full production auth stack.

New developers should assume:

- bearer token auth exists
- password hashing exists
- refresh tokens do not exist
- role-based auth does not exist yet
- frontend secure session persistence still needs to be built

## `users`

### Responsibilities

- fetch the authenticated user profile

This package is intentionally small right now.

Its main endpoint is:

- `GET /api/v1/me`

This package may later expand to support:

- profile updates
- preferences
- notification settings

## `venues`

### Responsibilities

- list discoverable venues
- provide venue-level location data

This package is important because it separates venue discovery from facility booking.

A venue is the map/discovery concept:

- a place
- an address
- coordinates

Examples:

- Khelgaah Central
- Khelgaah Arena

This is distinct from a facility, which is a bookable sports resource within a venue.

### Why This Separation Matters

If maps are added later, the map should usually show venues as pins, not individual bookings. So the venue concept deserves its own package and table.

## `facilities`

### Responsibilities

- return facility lists
- support search filtering

A facility is the bookable resource category the user sees in the app, such as:

- Tennis Court
- Swimming Pool
- Gym
- Badminton

This package supports:

- home screen listing
- search screen results
- entry into the booking flow

### Search Logic

The current implementation supports simple text filtering through SQL.

This is enough for the current product stage because:

- the data size is still small
- the search use case is straightforward
- full-text search or external indexing is not yet necessary

## `availability`

### Responsibilities

- compute bookable slots for a facility
- detect booking conflicts

This package is central to scheduling correctness.

### Why It Exists Separately

Showing availability and creating a booking are different operations.

Availability answers:

- what appears open to the user?

Booking answers:

- what is definitively reserved in the database?

Keeping them separate improves clarity.

### How Slot Generation Works

The current repository logic:

1. reads facility operating hours for the requested weekday
2. generates candidate slots over the requested day
3. compares each candidate slot against existing confirmed bookings
4. marks each slot as available or unavailable

This lets the frontend request availability dynamically based on:

- facility ID
- date
- duration

## `bookings`

### Responsibilities

- create bookings
- list bookings for a user

This is the highest-risk domain because it must prevent double-booking.

### Why `bookings` and `availability` Stay Separate

These packages both touch timeslots, but they own different responsibilities:

- `availability` is read-side scheduling logic
- `bookings` is write-side reservation logic

Keeping them separate helps preserve clarity and correctness.

### Transactional Booking Flow

When the booking service creates a booking, it:

1. parses the incoming start and end times
2. begins a database transaction
3. checks whether the requested time overlaps an existing confirmed booking
4. aborts if there is a conflict
5. inserts the new booking if no conflict exists
6. commits the transaction

This ensures that the backend, not the frontend, is the source of truth for availability.

### Why This Is Critical

The frontend can show availability, but the frontend view may be stale. Another user may book the same slot after availability was fetched.

That means the final booking decision must always happen on the backend inside a transaction.

## Domain Layering Pattern

Each domain generally follows this internal shape:

```text
handler -> service -> repository
```

### Handler

Handles HTTP concerns:

- route registration
- parameter parsing
- status codes
- request decoding
- response encoding

Handlers should not contain heavy business logic.

### Service

Handles business behavior:

- validation rules
- coordination of repository calls
- transaction boundaries
- workflow decisions

This is the main "application logic" layer.

### Repository

Handles persistence concerns:

- SQL queries
- row scanning
- database inserts and selects

Repositories should not be responsible for high-level business workflows.

## Current API Surface

The main routes are:

- `GET /healthz`
- `POST /api/v1/auth/signup`
- `POST /api/v1/auth/login`
- `GET /api/v1/me`
- `GET /api/v1/venues`
- `GET /api/v1/facilities`
- `GET /api/v1/facilities/{facilityID}/availability`
- `GET /api/v1/bookings`
- `POST /api/v1/bookings`

If you change these routes or payloads, update the docs and any frontend integration code accordingly.

## Routing Strategy

The backend uses Go’s standard HTTP multiplexer with route patterns.

Current endpoint groups include:

- health
- auth
- me
- venues
- facilities
- availability
- bookings

This gives a clean API surface without introducing a heavy web framework.

## Authentication Middleware

Protected routes use auth middleware.

The middleware flow is:

1. read `Authorization` header
2. extract bearer token
3. validate and parse token
4. extract user ID
5. inject user ID into request context
6. allow the handler to proceed

This means handlers for protected resources do not need to parse auth headers manually.

Examples of protected endpoints:

- `GET /api/v1/me`
- `GET /api/v1/bookings`
- `POST /api/v1/bookings`

## Request Lifecycle

A typical request flows through the system like this:

```text
client request
-> middleware
-> handler
-> service
-> repository
-> PostgreSQL
-> repository
-> service
-> handler
-> JSON response
```

### Example: Login

1. client sends credentials to `/api/v1/auth/login`
2. handler decodes JSON
3. service looks up the user
4. service compares the password hash
5. token manager issues a token
6. handler returns token + user JSON

### Example: Booking Creation

1. client sends booking data to `/api/v1/bookings`
2. auth middleware resolves current user
3. handler decodes JSON
4. service begins transaction
5. availability check runs
6. repository inserts booking
7. transaction commits
8. handler returns created booking

## Error Handling Philosophy

The backend already separates:

- client errors
- auth failures
- server failures

Examples:

- invalid JSON should be `400`
- invalid credentials should be `401`
- slot conflicts should be `409`
- internal failures should be `500`

This is important for frontend integration because the UI needs predictable failure semantics.

## Configuration and Runtime Assumptions

The backend expects runtime configuration primarily through:

- `DATABASE_URL`
- `AUTH_SECRET`
- `HTTP_ADDR`

A new developer should also know:

- PostgreSQL must be running
- the initial migration must be applied
- the backend depends on seeded development data for useful local responses

## Concurrency and Consistency

The most important backend design rule is:

- availability display is advisory
- booking confirmation is authoritative

This rule prevents the frontend from becoming the source of truth.

### Why Concurrency Matters

Imagine two users selecting the same badminton slot at nearly the same time.

If the backend simply trusted the frontend and inserted bookings without re-checking, the system could create double-bookings.

Instead, the backend:

- re-checks conflict state at booking time
- does so inside a transaction

That is the foundation of a reliable booking system.

## API Design Philosophy

The API is designed around product domains rather than UI widgets.

For example:

- auth endpoints deal with identity
- facility endpoints deal with discovery
- availability endpoints deal with schedules
- booking endpoints deal with reservations

This is better than designing endpoints directly around screens because screens can change more easily than domain boundaries.

## Current Limitations

The backend is intentionally focused on the MVP and does not yet include:

- refresh tokens
- role-based access for owners and organizers
- booking cancellation
- payment workflows
- map bounding-box queries
- caching
- background jobs
- admin dashboards

Those features can be added later without breaking the current modular structure.

## Development Discipline

When changing backend behavior:

1. identify the owning domain first
2. keep handlers thin
3. keep workflow logic in services
4. keep SQL in repositories
5. update docs when API contracts or domain assumptions change

## How the Backend Supports the Frontend

The backend directly matches the current Flutter app’s flows:

- auth screen -> auth endpoints
- home/search -> facilities endpoints
- booking screen -> availability + booking endpoints
- profile -> me + bookings endpoints
- future map screen -> venues endpoints

This is a strong sign that the current backend shape is aligned with the product.

## Summary

The backend is a modular Go monolith with clear domain separation.

Its design goals are:

- keep infrastructure simple
- keep business logic explicit
- keep booking consistency strong
- support the current player-facing flows cleanly

The most important architectural decision is the separation between:

- showing availability
- confirming a booking

That separation, combined with database-backed conflict checks, is what makes the system safe for real booking behavior.

## Onboarding Checklist

If you are starting backend work:

1. inspect `main.go` to see dependency wiring
2. trace one route end to end
3. inspect the relevant migration tables
4. verify whether the route is protected by auth middleware
5. preserve the booking conflict guarantees unless you are intentionally redesigning them
