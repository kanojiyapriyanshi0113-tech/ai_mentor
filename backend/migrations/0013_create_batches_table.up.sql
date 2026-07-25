-- +migrate Up
CREATE TABLE batches (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id     INTEGER NOT NULL REFERENCES exams (id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    thumbnail   VARCHAR(500),
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_batches_exam_id ON batches (exam_id);
CREATE INDEX idx_batches_is_active ON batches (is_active);
