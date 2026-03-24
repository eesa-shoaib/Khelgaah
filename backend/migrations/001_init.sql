CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    phone TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS venues (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS facilities (
    id BIGSERIAL PRIMARY KEY,
    venue_id BIGINT NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sport TEXT NOT NULL,
    type TEXT NOT NULL,
    open_summary TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS facility_operating_hours (
    id BIGSERIAL PRIMARY KEY,
    facility_id BIGINT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6),
    opens_at TIME NOT NULL,
    closes_at TIME NOT NULL,
    UNIQUE (facility_id, weekday)
);

CREATE TABLE IF NOT EXISTS bookings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    facility_id BIGINT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('confirmed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (end_time > start_time)
);

CREATE INDEX IF NOT EXISTS idx_bookings_facility_time ON bookings (facility_id, start_time, end_time);
CREATE INDEX IF NOT EXISTS idx_bookings_user ON bookings (user_id, start_time DESC);
CREATE INDEX IF NOT EXISTS idx_facilities_name ON facilities (name);

INSERT INTO venues (name, city, address, latitude, longitude)
VALUES
    ('Khelgaah Central', 'Lahore', 'MM Alam Road, Gulberg', 31.5204, 74.3587),
    ('Khelgaah Arena', 'Karachi', 'Clifton Block 5', 24.8138, 67.0306)
ON CONFLICT DO NOTHING;

INSERT INTO facilities (venue_id, name, sport, type, open_summary)
SELECT v.id, x.name, x.sport, x.type, x.open_summary
FROM venues v
JOIN (
    VALUES
        ('Khelgaah Central', 'Tennis Court', 'Tennis', 'Outdoor', '08 slots open'),
        ('Khelgaah Central', 'Swimming Pool', 'Swimming', 'Indoor', '05 slots open'),
        ('Khelgaah Arena', 'Gym', 'Fitness', 'Strength', 'Walk-ins available'),
        ('Khelgaah Arena', 'Badminton', 'Badminton', 'Court', '06 slots open')
) AS x(venue_name, name, sport, type, open_summary) ON v.name = x.venue_name
ON CONFLICT DO NOTHING;

INSERT INTO facility_operating_hours (facility_id, weekday, opens_at, closes_at)
SELECT f.id, d.weekday, '09:00'::time, '18:00'::time
FROM facilities f
CROSS JOIN (
    VALUES (0), (1), (2), (3), (4), (5), (6)
) AS d(weekday)
ON CONFLICT (facility_id, weekday) DO NOTHING;
