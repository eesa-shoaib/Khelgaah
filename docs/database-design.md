# Khelgaah Database Design

## Start Here

If you are onboarding onto the data model, read in this order:

1. `backend/migrations/001_init.sql`
2. `docs/database-design.md`
3. `docs/backend-design.md`

## Purpose

This document explains the PostgreSQL database in depth:

- what entities exist
- why the tables are shaped this way
- how data relationships work
- how availability and bookings are modeled
- how the schema supports the current frontend and backend

The current schema lives in:

```text
backend/migrations/001_init.sql
```

## Current Database Scope

The current database is intentionally compact. It models:

- players
- venues
- facilities
- recurring operating hours
- bookings

It does not yet model:

- owners
- tournament entities
- payments
- schedule exceptions
- multiple sub-units per facility

This is a deliberate MVP boundary, not an omission by accident.

## How to Read the Schema

A useful reading order is:

1. `bookings`
2. `users`
3. `facilities`
4. `venues`
5. `facility_operating_hours`

That mirrors the main booking flow.

## Why PostgreSQL

PostgreSQL is a strong fit for Khelgaah because the core problem is not only storing data. It is preserving correctness under concurrency.

This app needs the database to do several things well:

- enforce relational integrity
- support transactional booking writes
- support schedule and time-based queries
- support search/filter queries
- support future location queries

A relational database is the right default because the system has clear entities and strong relationships:

- users make bookings
- bookings belong to facilities
- facilities belong to venues
- schedules belong to facilities

This is a structured operational system, not an unstructured document workload.

## Current Schema Overview

The initial schema contains these main tables:

- `users`
- `venues`
- `facilities`
- `facility_operating_hours`
- `bookings`

These tables are enough to support the current player-facing flow:

- sign up and login
- discover venues/facilities
- inspect availability
- make bookings
- view profile/history

## Core Modeling Decisions

Three decisions shape the whole schema:

1. facilities are currently modeled as directly bookable resources
2. operating hours are recurring weekly rules
3. bookings are stored as time intervals, not label-based slots

Those choices explain most of the current schema behavior.

## Table-by-Table Design

## `users`

### Purpose

Stores the people using the app.

### Columns

- `id`
- `full_name`
- `email`
- `password_hash`
- `phone`
- `created_at`

### Why These Fields Exist

`email` is used for identity lookup at login.

`password_hash` is stored instead of plain passwords because the backend must never persist raw passwords.

`phone` supports contact and possible operational use later, such as notifications or booking coordination.

`created_at` helps with auditability and future analytics.

### Constraints

- `id` is the primary key
- `email` is unique

The unique email constraint ensures the same user cannot register multiple times under the same address.

## `venues`

### Purpose

Stores physical locations where sports facilities exist.

### Columns

- `id`
- `name`
- `city`
- `address`
- `latitude`
- `longitude`
- `created_at`

### Why Venue Is Its Own Table

Venue and facility are not the same concept.

A venue is:

- the place
- the address
- the map pin

A facility is:

- the specific sports resource the user books

For example:

- Venue: Khelgaah Central
- Facility: Tennis Court

This distinction is important for:

- map integration
- grouping multiple facilities under one location
- future owner dashboards

### Coordinates

`latitude` and `longitude` are stored directly in the venue table.

That is enough for initial map support and simple location display.

Later, if more advanced geospatial queries are needed, this can evolve into a PostGIS-backed geometry or geography column.

## `facilities`

### Purpose

Stores the bookable sports resources available within a venue.

### Columns

- `id`
- `venue_id`
- `name`
- `sport`
- `type`
- `open_summary`
- `created_at`

### Relationship

Each facility belongs to one venue:

- `venue_id -> venues.id`

This is a foreign key relationship.

### Meaning of Each Field

`name` is the frontend-facing label the user sees.

`sport` expresses the sports domain, such as Tennis or Swimming.

`type` gives an additional display category such as Outdoor, Indoor, Court, or Strength.

`open_summary` is currently used as a lightweight summary string for UI display. It is not the source of truth for availability.

### Important Design Note

The current schema treats facilities as bookable units directly. That is enough for the current frontend.

However, in a more advanced venue model, you may want to split this further into:

- facility category
- facility unit

For example:

- facility category: Badminton
- facility unit: Court 01, Court 02, Court 03

That would be useful if multiple units of the same sport can be booked independently.

The current schema is simpler and aligned with the current frontend prototype.

## `facility_operating_hours`

### Purpose

Stores recurring weekly operating hours for each facility.

### Columns

- `id`
- `facility_id`
- `weekday`
- `opens_at`
- `closes_at`

### Relationship

Each row belongs to one facility:

- `facility_id -> facilities.id`

### Why This Table Exists

Availability should not be stored as a giant static list of times. Instead, it should be derived from:

1. operating schedule
2. requested date
3. requested duration
4. existing bookings

This table provides the recurring schedule rule.

### Example

If a facility is open from `09:00` to `18:00` on Tuesday, the availability layer can generate candidate booking slots across that window.

### Constraint

There is a unique constraint on:

- `(facility_id, weekday)`

This prevents duplicate schedule rows for the same facility and day of week.

## `bookings`

### Purpose

Stores the reservations created by users.

### Columns

- `id`
- `user_id`
- `facility_id`
- `start_time`
- `end_time`
- `status`
- `created_at`

### Relationships

- `user_id -> users.id`
- `facility_id -> facilities.id`

### Why These Fields Exist

`user_id` links the booking back to the customer.

`facility_id` identifies what was reserved.

`start_time` and `end_time` define the booking window.

`status` allows lifecycle changes without deleting history. Right now the schema allows:

- `confirmed`
- `cancelled`

`created_at` captures when the reservation record was created.

### Integrity Constraint

There is a check constraint:

- `end_time > start_time`

This prevents invalid booking ranges.

### Why Time Range Modeling Matters

A booking is fundamentally a time interval.

The system does not merely care about a date label or slot label. It cares about whether one booking interval overlaps another.

That is why start and end timestamps are the core of the reservation model.

### Current Consistency Note

The current design enforces overlap protection primarily through backend transaction logic. The schema does not yet use a database-level exclusion constraint to make overlapping confirmed bookings impossible by table definition alone.

That is acceptable for the current stage, but new developers should understand where the guarantee lives today.

## Relationships Across the Schema

The main relationships are:

```text
users -> bookings
venues -> facilities
facilities -> facility_operating_hours
facilities -> bookings
```

This produces a clean operational model:

- users reserve facilities
- facilities exist inside venues
- operating hours define possible booking windows
- bookings consume those windows

## Query Patterns the Schema Is Optimized For

The main expected query patterns are:

- find a user by email
- list facilities for home/search
- list venues for discovery
- load operating hours by facility and weekday
- load bookings for a user
- check overlapping bookings for a facility and time range

## How Availability Is Computed

Availability is not stored directly in a dedicated table in the current design.

Instead, it is computed dynamically.

### Inputs to Availability

To calculate availability for a facility, the system uses:

1. requested facility
2. requested date
3. requested duration
4. operating hours for the facility on that weekday
5. confirmed bookings already stored for that time range

### Output

The result is a list of candidate slots, each marked as:

- available
- unavailable

### Why This Approach Is Better Than Pre-Storing Slots

Pre-storing every possible slot can become rigid and hard to maintain if:

- durations vary
- schedules change
- blackout periods are introduced
- custom rules are added

Dynamic generation is more flexible for the current use case.

## Schedule Semantics

The current schedule model assumes:

- one recurring open/close window per facility per weekday
- no holiday closures
- no split shifts
- no one-off overrides

That simplicity is intentional and should be kept in mind before assuming advanced scheduling behavior already exists.

## How Conflict Detection Works

The conflict rule is effectively:

- same facility
- confirmed status
- overlapping time interval

Cancelled bookings do not block availability.

This means booking status has operational meaning, not just display meaning.

The system checks for overlapping time intervals in the `bookings` table.

The logic is essentially:

- find confirmed bookings for the same facility
- determine whether the requested time range overlaps any of them

This is the core correctness rule for the booking system.

### Why Conflict Detection Must Happen at Write Time

Even if the frontend previously displayed the slot as available, that is not enough.

Another user may have booked it after the availability screen was loaded.

So the system must:

1. check availability when showing slots
2. check again when writing the booking

The second check is the authoritative one.

## Indexing Strategy

The current schema includes indexes on:

- booking facility/time range access
- user bookings
- facility name lookup

### Booking Index

The booking index supports:

- conflict checks
- time-range queries
- facility booking retrieval

This is essential because bookings are a frequently queried and correctness-critical table.

### User Booking Index

This supports profile/history use cases such as:

- show upcoming bookings
- show recent reservations

### Facility Name Index

This supports facility listing and text search.

## Seed Data

The migration also inserts initial seed data for:

- venues
- facilities
- operating hours

These values are development scaffolding. They make local development easier, but they are not production business rules.

This is useful because it lets the backend boot into a usable state for development.

### Why Seed Data Helps

Without seed data, the frontend and backend can run successfully but have nothing meaningful to display.

With seed data:

- home/search endpoints return useful results
- availability can be tested
- the booking flow can be exercised end to end

## What the Current Schema Supports Well

The current database design already supports:

- user registration and login
- facility discovery
- facility search
- schedule-based availability
- booking creation
- booking history
- future map display via venue coordinates

This is enough for an MVP focused on players.

## Current Schema Limitations

The current schema is intentionally simple. It does not yet support several concepts that may become necessary later.

### No Facility Units

The schema assumes each facility record is itself the bookable unit.

If a venue has multiple identical courts or lanes, a more detailed design would likely add:

- `facility_units`

This would allow the system to represent:

- Badminton Court 01
- Badminton Court 02
- Badminton Court 03

individually.

### No Owner Roles or Venue Management Tables

There is no current support for:

- venue owners
- staff accounts
- access control by role
- owner-managed schedules

These can be added later with tables such as:

- `owners`
- `venue_owners`
- `staff_users`

### No Blackout Dates or Exceptions

The current `facility_operating_hours` table models recurring weekly hours only.

It does not yet support:

- holiday closures
- maintenance blocks
- special event overrides
- one-off schedule exceptions

Those would likely require additional tables such as:

- `facility_schedule_exceptions`

### No Payments

The current schema does not include:

- invoices
- transactions
- payment methods
- refunds

That is appropriate for the current stage, because the first priority is booking correctness.

### No Audit Trail Table

There is no separate booking history log yet, beyond `status` and `created_at`.

If more detailed auditing is needed later, you may want:

- `booking_events`

to record each lifecycle transition.

## Migration Discipline

Treat schema work as normal application code:

1. add new migrations instead of rewriting historical ones casually
2. update backend queries and models together with schema changes
3. update docs when domain meanings change

## Recommended Future Database Growth

As Khelgaah evolves, the schema will likely expand in this direction:

1. split facilities into categories and units
2. add owner/organizer roles
3. add schedule exceptions
4. add payments
5. add tournament-related tables
6. add social/community data
7. add geospatial indexing with PostGIS

The current schema is a strong foundation for that growth because the primary relationships are already clear.

## How the Database Fits Into the Whole System

The frontend never talks to PostgreSQL directly.

Instead the interaction path is:

```text
Flutter UI -> Go API -> PostgreSQL
```

The database is therefore:

- the persistent storage layer
- the source of truth
- the consistency anchor for bookings

The backend interprets and protects the data.
The frontend displays and collects user input.

## Summary

The current database design is intentionally compact but structurally sound.

Its most important qualities are:

- relational integrity
- explicit booking intervals
- schedule-driven availability
- room to grow into maps, owners, and more advanced booking models

The most important concept to understand is that availability is derived, but bookings are stored. The schema is built around that distinction, which is exactly what a real booking platform needs.

## Onboarding Checklist

If you are starting database work:

1. read the migration file directly
2. identify the owning table for your concept
3. trace all related foreign keys
4. check whether your change affects availability, bookings, or both
5. update backend code and docs together with schema changes
