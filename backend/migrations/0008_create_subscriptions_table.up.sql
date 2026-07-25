-- +migrate Up
CREATE TABLE subscriptions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    plan_id     INT NOT NULL REFERENCES plans (id) ON DELETE RESTRICT,
    status      VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    started_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_subscriptions_user_id ON subscriptions (user_id);

CREATE TRIGGER trg_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Backfill existing users onto Free Trial, aligned to their existing trial window
INSERT INTO subscriptions (user_id, plan_id, status, started_at, expires_at)
SELECT u.id, p.id, 'active', u.trial_start_date, u.trial_end_date
FROM users u, plans p
WHERE p.code = 'free_trial'
ON CONFLICT (user_id) DO NOTHING;