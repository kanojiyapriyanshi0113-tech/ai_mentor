-- +migrate Up
CREATE TABLE user_content_progress (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    feature_key      VARCHAR(50) NOT NULL,
    resource_ordinal INT NOT NULL,
    completed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, feature_key, resource_ordinal)
);

CREATE INDEX idx_user_content_progress_user_feature ON user_content_progress (user_id, feature_key);
