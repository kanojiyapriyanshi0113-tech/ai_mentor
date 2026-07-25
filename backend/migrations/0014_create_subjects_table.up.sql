-- +migrate Up
CREATE TABLE subjects (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id      UUID NOT NULL REFERENCES batches (id) ON DELETE CASCADE,
    name          VARCHAR(200) NOT NULL,
    icon          VARCHAR(500),
    display_order INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_subjects_batch_id ON subjects (batch_id);
CREATE INDEX idx_subjects_batch_id_display_order ON subjects (batch_id, display_order);
