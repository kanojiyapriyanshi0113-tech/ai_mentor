-- +migrate Up
CREATE TABLE lectures (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id       UUID NOT NULL REFERENCES chapters (id) ON DELETE CASCADE,
    title            VARCHAR(200) NOT NULL,
    description      TEXT,
    duration_minutes INTEGER NOT NULL DEFAULT 0,
    video_url        VARCHAR(500) NOT NULL,
    is_preview       BOOLEAN NOT NULL DEFAULT false,
    display_order    INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_lectures_chapter_id ON lectures (chapter_id);
CREATE INDEX idx_lectures_chapter_id_display_order ON lectures (chapter_id, display_order);
