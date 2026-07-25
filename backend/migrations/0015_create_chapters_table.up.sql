-- +migrate Up
CREATE TABLE chapters (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id    UUID NOT NULL REFERENCES subjects (id) ON DELETE CASCADE,
    title         VARCHAR(200) NOT NULL,
    description   TEXT,
    display_order INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_chapters_subject_id ON chapters (subject_id);
CREATE INDEX idx_chapters_subject_id_display_order ON chapters (subject_id, display_order);
