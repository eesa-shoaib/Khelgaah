# Khelgaah Backend API

Go backend with PostgreSQL using `pgxpool`. No ORM - raw SQL with repository pattern.

**Tech Stack:** Go 1.26, PostgreSQL (pgx/v5), `net/http`

## Database

**DB:** `khelgaah_db` | **URL:** `postgres://postgres@localhost:5432/khelgaah_db?sslmode=disable`

**Tables:** users, venues, facilities, facility_operating_hours, bookings, time_slots, payments, disputes

*Migration 002 adds: user roles/status, venue owner/approval status, facility price/status, updated booking statuses, new time_slots/payments/disputes tables.*

## Quick Start

```bash
cd /home/eesa/projects/Khelgaah/backend && go run cmd/api/main.go
# Server: http://localhost:8080
```

## Endpoints

### Public

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/healthz` | Health check |
| POST | `/api/v1/auth/signup` | Register user (include `role`: customer/venue_owner/admin) |
| POST | `/api/v1/auth/login` | Login user |
| GET | `/api/v1/venues` | List venues |
| GET | `/api/v1/facilities?q=search` | List/filter facilities |
| GET | `/api/v1/facilities/{id}/availability?date=YYYY-MM-DD&duration=N` | Check slots |

### Customer Protected (Require `Authorization: Bearer <token>`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/me` | Get current user |
| POST | `/api/v1/bookings` | Create booking |
| GET | `/api/v1/bookings` | List my bookings |

### Venue Owner Protected (Require `Authorization: Bearer <venue_owner_token>`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/venue-owner/dashboard` | Owner dashboard stats |
| GET | `/api/v1/venue-owner/venues` | List owned venues |
| POST | `/api/v1/venue-owner/venues` | Create venue |
| GET | `/api/v1/venue-owner/venues/{id}` | Venue details |
| PUT | `/api/v1/venue-owner/venues/{id}` | Update venue |
| DELETE | `/api/v1/venue-owner/venues/{id}` | Delete venue |
| GET | `/api/v1/venue-owner/facilities` | List venue facilities |
| POST | `/api/v1/venue-owner/facilities` | Add facility |
| PUT | `/api/v1/venue-owner/facilities/{id}` | Update facility |
| DELETE | `/api/v1/venue-owner/facilities/{id}` | Delete facility |
| GET | `/api/v1/venue-owner/time-slots` | List time slots |
| POST | `/api/v1/venue-owner/time-slots` | Create time slot |
| DELETE | `/api/v1/venue-owner/time-slots/{id}` | Delete time slot |
| GET | `/api/v1/venue-owner/bookings` | List owner bookings |
| PUT | `/api/v1/venue-owner/bookings/{id}/approve` | Approve booking |
| PUT | `/api/v1/venue-owner/bookings/{id}/reject` | Reject booking |
| GET | `/api/v1/venue-owner/analytics` | Owner analytics |

### Admin Protected (Require `Authorization: Bearer <admin_token>`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/dashboard` | System-wide stats |
| GET | `/api/v1/admin/users` | List all users |
| GET | `/api/v1/admin/users/{id}` | User details |
| PUT | `/api/v1/admin/users/{id}/role` | Change user role |
| PUT | `/api/v1/admin/users/{id}/suspend` | Suspend user |
| PUT | `/api/v1/admin/users/{id}/activate` | Activate user |
| DELETE | `/api/v1/admin/users/{id}` | Delete user |
| GET | `/api/v1/admin/venues` | List all venues |
| PUT | `/api/v1/admin/venues/{id}/approve` | Approve venue |
| PUT | `/api/v1/admin/venues/{id}/reject` | Reject venue |
| PUT | `/api/v1/admin/venues/{id}/suspend` | Suspend venue |
| GET | `/api/v1/admin/bookings` | List all bookings |
| PUT | `/api/v1/admin/bookings/{id}/cancel` | Force cancel booking |
| PUT | `/api/v1/admin/bookings/{id}/complete` | Mark as completed |
| GET | `/api/v1/admin/payments` | List all payments |
| POST | `/api/v1/admin/payments/{id}/refund` | Process refund |
| GET | `/api/v1/admin/analytics` | System analytics |

## Curl Commands

```bash
# Health
curl http://localhost:8080/healthz

# Signup (specify role)
curl -X POST http://localhost:8080/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"full_name":"John","email":"john@test.com","phone":"1234567890","password":"pass123","role":"venue_owner"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@test.com","password":"pass123"}'

# Venues & Facilities
curl http://localhost:8080/api/v1/venues
curl http://localhost:8080/api/v1/facilities

# Availability
curl "http://localhost:8080/api/v1/facilities/1/availability?date=2026-05-02&duration=60"

# Customer Protected
curl -H "Authorization: Bearer <CUSTOMER_TOKEN>" http://localhost:8080/api/v1/me
curl -X POST http://localhost:8080/api/v1/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <CUSTOMER_TOKEN>" \
  -d '{"facility_id":1,"start_time":"2026-05-02T10:00:00Z","end_time":"2026-05-02T11:00:00Z"}'
curl -H "Authorization: Bearer <CUSTOMER_TOKEN>" http://localhost:8080/api/v1/bookings

# Venue Owner Protected
curl -H "Authorization: Bearer <VENUE_OWNER_TOKEN>" http://localhost:8080/api/v1/venue-owner/dashboard
curl -H "Authorization: Bearer <VENUE_OWNER_TOKEN>" http://localhost:8080/api/v1/venue-owner/venues
curl -X POST http://localhost:8080/api/v1/venue-owner/time-slots \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <VENUE_OWNER_TOKEN>" \
  -d '{"facility_id":1,"starts_at":"2026-05-02T10:00:00Z","ends_at":"2026-05-02T11:00:00Z","slot_type":"available"}'

# Admin Protected
curl -H "Authorization: Bearer <ADMIN_TOKEN>" http://localhost:8080/api/v1/admin/dashboard
curl -H "Authorization: Bearer <ADMIN_TOKEN>" http://localhost:8080/api/v1/admin/users
curl -X PUT http://localhost:8080/api/v1/admin/venues/1/approve \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
```

## PSQL Commands

```bash
# Connect to DB
psql -U postgres -d khelgaah_db

# List tables
\dt

# Check tables
SELECT * FROM users;
SELECT * FROM venues;
SELECT * FROM facilities;
SELECT * FROM facility_operating_hours;
SELECT * FROM bookings;
SELECT * FROM time_slots;
SELECT * FROM payments;
SELECT * FROM disputes;

# Exit
\q
```

## Notes

- Timestamps: RFC3339 format
- Changing `AUTH_SECRET` invalidates all tokens
- No CORS configured
