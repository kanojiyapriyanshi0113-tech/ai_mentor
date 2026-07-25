-- +migrate Up
CREATE TABLE user_usage (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    usage_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    feature_key VARCHAR(50) NOT NULL,
    used_count  INT NOT NULL DEFAULT 0,
    UNIQUE (user_id, usage_date, feature_key)
);
CREATE INDEX idx_user_usage_user_id_date ON user_usage (user_id, usage_date);