# How The Database Works

This project uses PostgreSQL.

The database is the storage layer for the Go backend. It keeps users, venues, facilities, operating hours, and bookings.

## 1. Main Idea

The backend reaches the database through repositories:

`handler -> service -> repository -> PostgreSQL`

This means SQL stays in repository code, while business rules stay in services.

## 2. Main Tables

- `users`: account and profile data
- `venues`: sports locations
- `facilities`: bookable spaces inside a venue
- `facility_operating_hours`: weekly opening hours for each facility
- `bookings`: who booked what time slot

## 3. How Tables Connect

- one venue has many facilities
- one facility has many operating-hour rows
- one user can have many bookings
- one facility can have many bookings

These links are enforced with foreign keys.

## 4. Why PostgreSQL Fits

PostgreSQL is a good fit here because it gives:

- strong relational structure
- transactions for safe booking creation
- constraints to block bad data
- indexes for faster search and booking lookup

## 5. How It Is Added

The schema starts in `backend/migrations/001_init.sql`.

To add database changes:

1. update or add a migration file
2. apply the migration to PostgreSQL
3. update the related repository code in Go
4. keep validation rules in services

That keeps the database layer simple and consistent with `docs/backend.md`.
