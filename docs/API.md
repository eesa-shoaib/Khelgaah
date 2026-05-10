# Khelgaah Backend API

Go backend with PostgreSQL using `pgxpool`. No ORM - raw SQL with repository pattern.

**Tech Stack:** Go 1.26+, PostgreSQL (pgx/v5), `net/http` (no framework)

## Database

**DB:** `khelgaah_db` | **URL:** `postgres://postgres@localhost:1234/db?sslmode=disable`

**Tables:** users, venues, facilities, facility_operating_hours, bookings, time_slots, payments, disputes

*Migration 002 adds: user roles/status, venue owner/approval status, facility price/status, updated booking statuses, new time_slots/payments/disputes tables.*

## Quick Start

```bash
cd /home/eesa/projects/Khelgaah/backend && go run cmd/api/main.go
# Server: http://localhost:8080
```

## Auth & Roles

**Signup Constraints:**
- Only `customer` and `venue_owner` roles allowed during signup
- Admin must be created via admin panel (change role) or seed command
- Passwords must be at least 8 characters

**Roles:**
- `customer`: Browse venues, book facilities, view own bookings
- `venue_owner`: Manage own venues, facilities, time slots, bookings
- `admin`: Full system access, user management, venue approval, analytics

## Endpoints

### Public

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/healthz` | Health check |
| POST | `/api/v1/auth/signup` | Register user (role: customer/venue_owner only) |
| POST | `/api/v1/auth/login` | Login user |
| GET | `/api/v1/venues` | List approved venues |
| GET | `/api/v1/facilities?q=search` | List/filter facilities |
| GET | `/api/v1/facilities/{id}/availability?date=YYYY-MM-DD&duration=N` | Check available slots |

**Availability Rules:**
- Returns time slots created by venue owner (`time_slots` table with `slot_type='available'`)
- If no owner-created slots exist for the facility/day, returns empty list
- Customers see only slots the venue owner has explicitly created
- Booked slots and blocked slots are marked accordingly

### Customer (Require `Authorization: Bearer <token>`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/me` | Get current user profile |
| PUT | `/api/v1/me` | Update profile |
| POST | `/api/v1/bookings` | Create booking request |
| GET | `/api/v1/bookings` | List own bookings |
| GET | `/api/v1/bookings/{id}` | Get booking details |
| POST | `/api/v1/bookings/{id}/cancel` | Cancel own booking |

**Booking Flow:**
1. Customer selects facility and time slot
2. Booking created with `status: pending`
3. Venue owner approves/rejects
4. If approved, customer can use facility

### Venue Owner (Require `Authorization: Bearer <venue_owner_token>` + `venue_owner` role)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/venue-owner/dashboard` | Dashboard stats (venues, facilities, bookings, revenue, occupancy) |
| GET | `/api/v1/venue-owner/venues` | List owned venues |
| POST | `/api/v1/venue-owner/venues` | Create venue |
| GET | `/api/v1/venue-owner/venues/{id}` | Venue details |
| PUT | `/api/v1/venue-owner/venues/{id}` | Update venue |
| DELETE | `/api/v1/venue-owner/venues/{id}` | Delete venue |
| GET | `/api/v1/venue-owner/facilities` | List owned facilities (by venue) |
| POST | `/api/v1/venue-owner/venues/{venueId}/facilities` | Add facility |
| GET | `/api/v1/venue-owner/facilities/{id}` | Facility details |
| PUT | `/api/v1/venue-owner/facilities/{id}` | Update facility |
| DELETE | `/api/v1/venue-owner/facilities/{id}` | Delete facility |
| GET | `/api/v1/venue-owner/facilities/{id}/time-slots` | List time slots for facility |
| POST | `/api/v1/venue-owner/facilities/{id}/time-slots` | Create time slot |
| PUT | `/api/v1/venue-owner/facilities/{id}/time-slots/{slotId}` | Update time slot |
| DELETE | `/api/v1/venue-owner/facilities/{id}/time-slots/{slotId}` | Delete time slot |
| GET | `/api/v1/venue-owner/bookings` | List owner bookings |
| PUT | `/api/v1/venue-owner/bookings/{id}/approve` | Approve booking |
| PUT | `/api/v1/venue-owner/bookings/{id}/reject` | Reject booking |
| PUT | `/api/v1/venue-owner/bookings/{id}/cancel` | Cancel booking |
| GET | `/api/v1/venue-owner/analytics` | Revenue charts, booking trends |

### Admin (Require `Authorization: Bearer <admin_token>` + `admin` role)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/dashboard` | System stats (users, venues, bookings, revenue) |
| GET | `/api/v1/admin/users` | List all users (filter: role, status) |
| GET | `/api/v1/admin/users/{id}` | User details |
| PUT | `/api/v1/admin/users/{id}/role` | Change user role (to customer/venue_owner/admin) |
| PUT | `/api/v1/admin/users/{id}/suspend` | Suspend user |
| DELETE | `/api/v1/admin/users/{id}` | Delete user |
| GET | `/api/v1/admin/venues` | List all venues (filter: status) |
| PUT | `/api/v1/admin/venues/{id}/approve` | Approve venue |
| PUT | `/api/v1/admin/venues/{id}/reject` | Reject venue |
| PUT | `/api/v1/admin/venues/{id}/suspend` | Suspend venue |
| GET | `/api/v1/admin/bookings` | List all bookings (filter: status) |
| PUT | `/api/v1/admin/bookings/{id}/cancel` | Force cancel booking |
| PUT | `/api/v1/admin/bookings/{id}/resolve` | Resolve booking dispute |
| GET | `/api/v1/admin/payments` | List all payments (filter: status) |
| POST | `/api/v1/admin/payments/{bookingId}/refund` | Process refund |
| GET | `/api/v1/admin/analytics` | System analytics |

## Curl Commands

```bash
# Health
curl http://localhost:8080/healthz

# Signup (customer or venue_owner only)
curl -X POST http://localhost:8080/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"full_name":"John","email":"john@test.com","phone":"1234567890","password":"pass1234","role":"venue_owner"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@test.com","password":"pass1234"}'

# Public endpoints
curl http://localhost:8080/api/v1/venues
curl http://localhost:8080/api/v1/facilities

# Availability (shows owner-created slots only)
curl "http://localhost:8080/api/v1/facilities/1/availability?date=2026-05-02&duration=60"

# Customer endpoints
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/me
curl -X POST http://localhost:8080/api/v1/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"facility_id":1,"start_time":"2026-05-02T10:00:00Z","end_time":"2026-05-02T11:00:00Z"}'
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/bookings
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/bookings/1
curl -X POST http://localhost:8080/api/v1/bookings/1/cancel \
  -H "Authorization: Bearer <TOKEN>"

# Venue Owner endpoints
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/venue-owner/dashboard
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/venue-owner/venues

# Create time slot (this is what customers will see in availability)
curl -X POST http://localhost:8080/api/v1/venue-owner/facilities/1/time-slots \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"starts_at":"2026-05-02T09:00:00Z","ends_at":"2026-05-02T10:00:00Z","slot_type":"available"}'

# Venue Owner bookings
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/venue-owner/bookings
curl -X PUT http://localhost:8080/api/v1/venue-owner/bookings/1/approve \
  -H "Authorization: Bearer <TOKEN>"

# Admin endpoints
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/admin/dashboard
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/admin/users
curl -X PUT http://localhost:8080/api/v1/admin/users/2/role \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"role":"admin"}'
curl -X PUT http://localhost:8080/api/v1/admin/venues/1/approve \
  -H "Authorization: Bearer <TOKEN>"
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/admin/payments
```

## PSQL Commands

```bash
# Connect to DB
psql -U postgres -d khelgaah_db

# List tables
\dt

# Check users (note role column)
SELECT id, email, full_name, role, status FROM users;

# Check venues (note approval_status)
SELECT id, name, owner_user_id, approval_status FROM venues;

# Check facilities
SELECT id, venue_id, name, price_per_hour, open_time, close_time FROM facilities;

# Check time slots (owner-created)
SELECT id, facility_id, starts_at, ends_at, slot_type, status FROM time_slots;

# Check bookings
SELECT id, user_id, facility_id, status, payment_status FROM bookings;

# Check payments
SELECT id, booking_id, amount, status, method FROM payments;
```

## Admin User Creation

Since signup blocks admin role, there are several ways to create an admin:

1. **Via existing admin:** Use `PUT /api/v1/admin/users/{id}/role` to change a user's role to `admin`
2. **Via seed command (TODO):** `go run cmd/seed/main.go --create-admin email@domain.com`
3. **Via database:** Insert directly into users table with `role='admin'`

## Notes

- Timestamps: RFC3339 format (e.g., `2026-05-02T10:00:00Z`)
- Changing `AUTH_SECRET` invalidates all existing tokens
- No CORS configured (frontend and backend must be on same origin or use proxy)
- Venue must be `approved` status to appear in public listings
- Booking status flow: `pending` → `confirmed`/`rejected` → `completed`/`cancelled`/`disputed`
