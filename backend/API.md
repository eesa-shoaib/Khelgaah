# Khelgaah Backend API

Go backend with PostgreSQL using `pgxpool`. No ORM - raw SQL with repository pattern.

**Tech Stack:** Go 1.26, PostgreSQL (pgx/v5), `net/http`

## Database

**DB:** `khelgaah_db` | **URL:** `postgres://postgres@localhost:5432/khelgaah_db?sslmode=disable`

**Tables:** users, venues, facilities, facility_operating_hours, bookings

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
| POST | `/api/v1/auth/signup` | Register user |
| POST | `/api/v1/auth/login` | Login user |
| GET | `/api/v1/venues` | List venues |
| GET | `/api/v1/facilities?q=search` | List/filter facilities |
| GET | `/api/v1/facilities/{id}/availability?date=YYYY-MM-DD&duration=N` | Check slots |

### Protected (Require `Authorization: Bearer <token>`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/me` | Get current user |
| POST | `/api/v1/bookings` | Create booking |
| GET | `/api/v1/bookings` | List my bookings |

## Curl Commands

```bash
# Health
curl http://localhost:8080/healthz

# Signup
curl -X POST http://localhost:8080/api/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"full_name":"John","email":"john@test.com","phone":"1234567890","password":"pass123"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@test.com","password":"pass123"}'

# Venues & Facilities
curl http://localhost:8080/api/v1/venues
curl http://localhost:8080/api/v1/facilities

# Availability
curl "http://localhost:8080/api/v1/facilities/1/availability?date=2026-05-02&duration=60"

# Protected (use token from login)
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/me
curl -X POST http://localhost:8080/api/v1/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"facility_id":1,"start_time":"2026-05-02T10:00:00Z","end_time":"2026-05-02T11:00:00Z"}'
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8080/api/v1/bookings
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

# Exit
\q
```

## Notes

- Timestamps: RFC3339 format
- Changing `AUTH_SECRET` invalidates all tokens
- No CORS configured
