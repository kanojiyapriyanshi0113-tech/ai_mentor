ALTER TABLE batches ADD COLUMN IF NOT EXISTS is_published BOOLEAN NOT NULL DEFAULT false;
CREATE INDEX IF NOT EXISTS idx_batches_is_published ON batches (is_published);

CREATE TABLE IF NOT EXISTS pdfs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id    UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    title         VARCHAR(200) NOT NULL,
    file_url      VARCHAR(500) NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_pdfs_chapter_id ON pdfs (chapter_id);
CREATE INDEX IF NOT EXISTS idx_pdfs_is_active ON pdfs (is_active) WHERE is_active = true;

CREATE TABLE IF NOT EXISTS mock_tests (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id          UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    title             VARCHAR(200) NOT NULL,
    duration_minutes  INTEGER NOT NULL DEFAULT 0,
    total_questions   INTEGER NOT NULL DEFAULT 0,
    is_active         BOOLEAN NOT NULL DEFAULT true,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_mock_tests_batch_id ON mock_tests (batch_id);
CREATE INDEX IF NOT EXISTS idx_mock_tests_is_active ON mock_tests (is_active) WHERE is_active = true;

CREATE TABLE IF NOT EXISTS pyqs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id      UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    exam_name     VARCHAR(200) NOT NULL,
    year          INTEGER NOT NULL,
    subject_tag   VARCHAR(100) NOT NULL DEFAULT '',
    file_url      VARCHAR(500) NOT NULL,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_pyqs_batch_id ON pyqs (batch_id);
CREATE INDEX IF NOT EXISTS idx_pyqs_is_active ON pyqs (is_active) WHERE is_active = true;

CREATE TABLE IF NOT EXISTS live_classes (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id      UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    title         VARCHAR(200) NOT NULL,
    scheduled_at  TIMESTAMPTZ NOT NULL,
    meeting_url   VARCHAR(500) NOT NULL DEFAULT '',
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_live_classes_batch_id ON live_classes (batch_id);
CREATE INDEX IF NOT EXISTS idx_live_classes_scheduled_at ON live_classes (scheduled_at);

CREATE TABLE IF NOT EXISTS notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id    UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    sender_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       VARCHAR(200) NOT NULL,
    message     TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_notifications_batch_id ON notifications (batch_id);