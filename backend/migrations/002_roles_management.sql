ALTER TABLE users
    ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'customer'
        CHECK (role IN ('customer', 'venue_owner', 'admin')),
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'suspended', 'deleted')),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_users_role_status ON users (role, status);

ALTER TABLE venues
    ADD COLUMN IF NOT EXISTS owner_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS approval_status TEXT NOT NULL DEFAULT 'approved'
        CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_venues_owner ON venues (owner_user_id);
CREATE INDEX IF NOT EXISTS idx_venues_approval_status ON venues (approval_status);

ALTER TABLE facilities
    ADD COLUMN IF NOT EXISTS price_per_hour NUMERIC(12,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive', 'maintenance')),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_facilities_venue_status ON facilities (venue_id, status);

ALTER TABLE bookings
    DROP CONSTRAINT IF EXISTS bookings_status_check;

ALTER TABLE bookings
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS notes TEXT NOT NULL DEFAULT '';

ALTER TABLE bookings
    ADD CONSTRAINT bookings_status_check
        CHECK (status IN ('pending', 'confirmed', 'rejected', 'cancelled', 'completed', 'disputed'));

UPDATE bookings
SET status = 'confirmed'
WHERE status NOT IN ('pending', 'confirmed', 'rejected', 'cancelled', 'completed', 'disputed');

CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (status, start_time DESC);

CREATE TABLE IF NOT EXISTS time_slots (
    id BIGSERIAL PRIMARY KEY,
    facility_id BIGINT NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    slot_type TEXT NOT NULL CHECK (slot_type IN ('available', 'blocked')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'cancelled')),
    reason TEXT NOT NULL DEFAULT '',
    created_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);

CREATE INDEX IF NOT EXISTS idx_time_slots_facility_range ON time_slots (facility_id, starts_at, ends_at);
CREATE INDEX IF NOT EXISTS idx_time_slots_type_status ON time_slots (slot_type, status);

CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    currency TEXT NOT NULL DEFAULT 'PKR',
    method TEXT NOT NULL DEFAULT 'manual',
    status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
    provider_reference TEXT NOT NULL DEFAULT '',
    notes TEXT NOT NULL DEFAULT '',
    paid_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_booking_status ON payments (booking_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_status_created ON payments (status, created_at DESC);

CREATE TABLE IF NOT EXISTS disputes (
    id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    opened_by_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved', 'rejected')),
    resolution_notes TEXT NOT NULL DEFAULT '',
    resolved_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_disputes_booking_status ON disputes (booking_id, status);
