-- +migrate Up
CREATE TABLE user_exams (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    exam_id      INT  NOT NULL REFERENCES exams (id) ON DELETE RESTRICT,
    selected_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, exam_id)
);

CREATE INDEX idx_user_exams_user_id ON user_exams (user_id);
