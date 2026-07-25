-- +migrate Up
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name              VARCHAR(100) NOT NULL,
    email             VARCHAR(150) NOT NULL UNIQUE,
    password_hash     VARCHAR(255),
    google_id         VARCHAR(255) UNIQUE,
    is_verified       BOOLEAN NOT NULL DEFAULT FALSE,
    premium           BOOLEAN NOT NULL DEFAULT FALSE,
    trial_start_date  TIMESTAMPTZ NOT NULL DEFAULT now(),
    trial_end_date    TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT users_auth_method_check
        CHECK (password_hash IS NOT NULL OR google_id IS NOT NULL)
);

CREATE INDEX idx_users_email ON users (email);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
