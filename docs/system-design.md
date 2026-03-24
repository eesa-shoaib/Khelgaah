# Khelgaah System Design

## Start Here

If you are new to the project, read the docs in this order:

1. `docs/system-design.md`
2. `docs/frontend-design.md`
3. `docs/backend-design.md`
4. `docs/database-design.md`

This document gives the cross-system view. The other documents go deeper into each layer.

## Purpose

This document explains:

- what the current Flutter frontend is doing
- what the Go backend is doing
- how PostgreSQL fits into the system
- how the pieces interact during common user flows

The current product is a sports facility booking app. A user can sign in, browse facilities, search them, inspect availability, and create bookings.

## Project Status

The project is currently in a split state:

- the frontend is still partly prototype-driven
- the backend is now API-driven
- the database schema supports the first real booking flow

This is important for onboarding because it explains why some frontend screens still use hardcoded data while the backend already expects real identifiers and timestamps.

## Repo Map

The main project directories are:

```text
frontend/   Flutter application
backend/    Go API and SQL migrations
docs/       architecture and onboarding documents
database/   currently unused placeholder directory
```

Most product work currently happens in:

- `frontend/lib`
- `backend/internal`
- `backend/migrations`
- `docs`

## High-Level Architecture

The system is split into three main parts:

1. Flutter frontend
2. Go backend API
3. PostgreSQL database

At a high level, the flow is:

```text
Flutter app -> HTTP/JSON API -> Go services -> PostgreSQL
```

The frontend is the user-facing client.
The backend contains the business logic and validation.
The database is the source of truth for users, venues, facilities, schedules, and bookings.

## Core Domain Terms

A new developer should align on these terms:

- `User`: the player using the app
- `Venue`: a physical location, used for discovery and maps
- `Facility`: a bookable sports resource inside a venue
- `Availability`: computed open or occupied time windows for a facility
- `Booking`: a confirmed reservation for a facility and time range

The current system does not yet model per-facility sub-units like `Court 01` and `Court 02` separately.

## Frontend Overview

The frontend lives in `frontend/lib`.

### Entry Flow

- `main.dart` starts the Flutter app.
- `app.dart` creates the root `MaterialApp`.
- The app currently launches into `AuthScreen`.

This means the first experience is authentication, after which the user is moved into the main app layout.

### Main Screens

#### Auth

File: `frontend/lib/features/auth/auth_screen.dart`

This screen handles:

- sign in mode
- sign up mode
- collecting user credentials
- navigating into the app after authentication

Right now the screen is mostly a UI prototype. It collects fields like full name, email, password, and phone, but it does not yet call the backend. In the finished system, this screen should call:

- `POST /api/v1/auth/signup`
- `POST /api/v1/auth/login`

The backend will return an auth token and the authenticated user object. The app should then store that token and include it in future requests.

#### Main Layout

File: `frontend/lib/features/main_layout.dart`

This is the shell of the app after login. It uses an `IndexedStack` with a bottom navigation bar. Right now it switches between:

- Home
- Search

This is where the app controls top-level navigation between core booking flows.

#### Home

File: `frontend/lib/features/home/home_screen.dart`

This screen currently shows:

- a short intro
- a "next reservation" summary card
- a list of facilities
- a shortcut into search

At the moment, the facility list is hardcoded in the widget. In the final version, this list should come from the backend, most likely from:

- `GET /api/v1/facilities`

The booking summary card should eventually come from:

- `GET /api/v1/bookings`

filtered to the next upcoming booking for the current user.

#### Search

File: `frontend/lib/features/search/search_screen.dart`

This screen lets the user search facilities. Right now:

- the facility dataset is hardcoded
- filtering happens entirely in memory in Flutter

In the real system, this should become a server-backed query. The frontend should send the search text to:

- `GET /api/v1/facilities?q=...`

The backend should search facility names, sport types, and facility categories, then return matching results.

#### Booking

File: `frontend/lib/features/booking/booking_screen.dart`

This is the most important user flow in the app. It currently lets the user:

- choose a day
- choose a duration
- choose an available time slot
- confirm the booking

The current UI uses hardcoded day lists, time slots, and unavailable slots. In the real system:

- the selected facility ID is passed from the previous screen
- the app calls `GET /api/v1/facilities/{facilityID}/availability?date=...&duration=...`
- the backend returns which slots are available
- when the user confirms, the app calls `POST /api/v1/bookings`

This is the screen where frontend and backend must stay tightly aligned, because availability must be correct and booking confirmation must be transactional.

#### Profile

File: `frontend/lib/features/profile/profile_screen.dart`

This screen currently shows:

- the user header
- booking history placeholder
- settings placeholder
- logout

Right now it is still mostly static UI. In the real system:

- profile data should come from `GET /api/v1/me`
- booking history should come from `GET /api/v1/bookings`
- logout should clear the saved auth token locally

### Frontend State Today

The frontend is best understood as a polished UI prototype. It already defines the product flows clearly, but most business data is still hardcoded inside widgets.

That means the frontend already tells us what backend capabilities are needed, even before it is fully integrated:

- user authentication
- facility discovery
- search
- slot availability
- booking creation
- booking history

## Backend Overview

The backend lives in `backend`.

It is a modular Go monolith, not a microservice system. That is the right choice at this stage because the app is still early and the domains are tightly connected.

### Entry Point

File: `backend/cmd/api/main.go`

This file wires the whole backend together:

- loads configuration
- opens the PostgreSQL connection pool
- creates repositories
- creates services
- creates handlers
- registers HTTP routes
- starts the HTTP server

This file is the composition root. It does not contain business logic. Its job is to connect the modules.

### Backend Package Structure

The backend uses domain-oriented packages inside `backend/internal`.

#### `auth`

Responsibilities:

- sign up
- login
- password hashing
- token issuance

Main idea:

- handler receives HTTP request
- service validates and performs auth logic
- repository reads/writes users in PostgreSQL
- token manager signs the auth token

#### `users`

Responsibilities:

- fetch the authenticated user profile

This is a small domain right now. It reads the current user from the database and returns profile data.

#### `venues`

Responsibilities:

- return venue data
- support discovery and map integration later

This package is where venue-level location data belongs, such as city, address, latitude, and longitude.

#### `facilities`

Responsibilities:

- list facilities
- filter facilities by search query

This supports both the home screen and the search screen.

#### `availability`

Responsibilities:

- calculate bookable slots for a facility on a given date and duration
- check whether a requested time range conflicts with an existing booking

This package is important because it separates "show open slots" from "create a booking". That makes the system easier to reason about.

#### `bookings`

Responsibilities:

- create bookings
- list bookings for the current user

This package is the consistency-critical part of the backend. It uses a database transaction when creating a booking.

#### `platform`

Responsibilities:

- config loading
- DB pool setup
- logging
- middleware
- JSON helpers

This package contains shared infrastructure so domain packages stay focused on business behavior.

## Backend Design Pattern

Each domain follows the same layered shape:

```text
HTTP handler -> service -> repository -> PostgreSQL
```

### Handler

The handler is the HTTP layer. It:

- reads path params, query params, and JSON bodies
- validates request shape
- calls the service
- writes JSON responses

Handlers should stay thin.

### Service

The service contains business logic. It:

- decides what should happen
- coordinates repositories
- applies rules
- manages transactions when needed

This is where system behavior belongs.

### Repository

The repository contains SQL access. It:

- reads data from PostgreSQL
- inserts or updates records
- hides SQL details from the service layer

This keeps database concerns isolated.

## Current API Contract

The main backend endpoints are:

- `POST /api/v1/auth/signup`
- `POST /api/v1/auth/login`
- `GET /api/v1/me`
- `GET /api/v1/venues`
- `GET /api/v1/facilities`
- `GET /api/v1/facilities/{facilityID}/availability`
- `GET /api/v1/bookings`
- `POST /api/v1/bookings`

This contract is the intended integration boundary between Flutter and Go.

## System Invariants

These are the rules a new developer should preserve:

- the frontend is not the source of truth for availability
- the backend must re-check conflicts before confirming a booking
- the database is the authoritative store for core business data
- protected endpoints derive the current user from the bearer token, not from client-supplied user IDs

## Database Design

The schema lives in:

- `backend/migrations/001_init.sql`

### Core Tables

#### `users`

Stores:

- full name
- email
- password hash
- phone
- created time

This supports sign up, login, and profile.

#### `venues`

Stores:

- venue name
- city
- address
- latitude
- longitude

This is the map/discovery layer of the system.

#### `facilities`

Stores:

- which venue the facility belongs to
- facility name
- sport
- type
- availability summary label

Examples:

- Tennis Court
- Swimming Pool
- Gym
- Badminton

This supports both listing and search.

#### `facility_operating_hours`

Stores weekly schedule rules for each facility:

- weekday
- open time
- close time

This lets the backend generate candidate time slots for a requested day.

#### `bookings`

Stores:

- which user made the booking
- which facility was booked
- start time
- end time
- booking status

This is the core transactional table.

## Why Availability Is Separate From Bookings

The system treats availability and bookings as related but different concerns.

Availability answers:

- what could be booked?
- which slots are free right now?

Bookings answer:

- what has actually been reserved?

The backend computes availability by combining:

1. facility operating hours
2. requested date
3. requested duration
4. existing confirmed bookings

This is why the booking screen should not trust the UI alone. A slot can appear free on screen, but another user may book it before confirmation. The backend must re-check availability during booking creation.

## Authentication Flow

The current backend uses token-based authentication.

### Signup

1. Frontend collects user data on the auth screen.
2. Frontend sends `POST /api/v1/auth/signup`.
3. Backend hashes the password.
4. Backend inserts the user in `users`.
5. Backend issues a signed token.
6. Backend returns token + user object.

### Login

1. Frontend sends `POST /api/v1/auth/login`.
2. Backend loads the user by email.
3. Backend compares password against stored hash.
4. Backend issues a signed token.
5. Frontend stores that token locally.

### Authenticated Requests

For protected endpoints, the frontend sends:

```text
Authorization: Bearer <token>
```

The auth middleware:

1. extracts the token from the header
2. validates it
3. reads the user ID from the token
4. puts the user ID into request context

Then downstream handlers can fetch the current user ID safely.

## Main Request Flows

### Flow 1: User Opens Home Screen

Target frontend screen:

- `home_screen.dart`

Expected backend interactions:

1. frontend loads facility list from `GET /api/v1/facilities`
2. frontend loads user bookings from `GET /api/v1/bookings`
3. frontend shows the nearest upcoming booking in the summary card
4. frontend renders facility cards from the API response

### Flow 2: User Searches for a Facility

Target frontend screen:

- `search_screen.dart`

Expected backend interaction:

1. user types a search term
2. frontend sends `GET /api/v1/facilities?q=badminton`
3. backend queries PostgreSQL with text filters
4. backend returns matching facilities
5. frontend renders the results list

### Flow 3: User Checks Availability

Target frontend screen:

- `booking_screen.dart`

Expected backend interaction:

1. user selects a facility, date, and duration
2. frontend sends `GET /api/v1/facilities/{facilityID}/availability?...`
3. backend reads operating hours
4. backend generates candidate slots
5. backend removes slots that overlap existing confirmed bookings
6. backend returns available and unavailable slots
7. frontend renders slot buttons accordingly

### Flow 4: User Confirms a Booking

This is the critical consistency flow.

1. user taps confirm in the booking screen
2. frontend sends `POST /api/v1/bookings`
3. booking handler reads the authenticated user from request context
4. booking service starts a database transaction
5. service re-checks whether the requested slot conflicts with an existing confirmed booking
6. if there is a conflict, backend returns `409 Conflict`
7. if there is no conflict, backend inserts the booking
8. transaction commits
9. backend returns the confirmed booking
10. frontend updates the UI

This protects the system from double-booking even if two users try to reserve the same slot at nearly the same time.

### Flow 5: User Opens Profile

Target frontend screen:

- `profile_screen.dart`

Expected backend interactions:

1. frontend calls `GET /api/v1/me`
2. frontend optionally calls `GET /api/v1/bookings`
3. backend returns user profile and booking history
4. frontend renders profile data and recent bookings

## Why the Backend Is Modular

The backend is modular so different concerns do not get mixed together.

Without modularity, booking logic, auth logic, search logic, and database code would end up in the same place. That would make the system hard to change and risky to extend.

With the current layout:

- auth can evolve without touching booking logic
- map-based venue discovery can evolve inside `venues`
- booking rules can grow inside `bookings` and `availability`
- infrastructure can change without rewriting domain logic

This is especially useful for Khelgaah because the product will likely expand later into:

- owner dashboards
- tournament management
- social/community features
- location-based discovery

## Current Frontend vs Backend Reality

There is one important distinction:

- the backend is now real and API-driven
- the frontend is still largely UI-first and hardcoded

So the system is currently in a transitional state:

1. frontend screens already define the user experience
2. backend now defines the real data model and API
3. the next step is integration, where Flutter replaces hardcoded lists with HTTP calls

## Future Map Integration

The current backend already includes a `venues` domain and stores:

- latitude
- longitude
- address
- city

That means maps can be added cleanly later.

The intended map flow is:

1. frontend opens a map view
2. frontend requests venue data from `GET /api/v1/venues`
3. backend returns venue markers with coordinates
4. frontend places pins on the map
5. user taps a pin
6. app opens the related venue or facility booking flow

If nearby search becomes important later, PostgreSQL can be extended with PostGIS.

## Summary

The current system design is:

- Flutter defines the user journeys
- Go implements the business logic behind those journeys
- PostgreSQL stores the source-of-truth data

The frontend currently demonstrates the product behavior with static data.
The backend now provides the real modular architecture needed to replace that static data.
The most important system rule is that booking correctness is enforced on the backend, not in the UI.

That rule is what keeps the system reliable as real users begin booking the same facilities concurrently.

## Onboarding Checklist

If you are new to the project:

1. read this document first
2. trace one flow end to end, ideally `login` or `create booking`
3. note where the frontend is still mocked
4. inspect the corresponding backend domain package
5. inspect the relevant tables in `backend/migrations/001_init.sql`
