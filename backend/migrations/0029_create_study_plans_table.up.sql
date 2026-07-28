-- +migrate Up
CREATE TABLE study_plans (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    date         TIMESTAMPTZ NOT NULL,
    goal         VARCHAR(500) NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT false,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_study_plans_user_id ON study_plans (user_id, date DESC);