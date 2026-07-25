-- =====================================================================
-- Migration: 005_create_course_management_tables
-- Purpose:   Course Management schema (batches -> subjects -> chapters -> lectures)
--            with subscription / free-trial access support.
-- Depends on: exams(id) already existing from prior migrations.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- Extension needed for gen_random_uuid()
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- Shared trigger function to auto-maintain updated_at
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- BATCHES
-- =====================================================================
CREATE TABLE batches (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id        INTEGER NOT NULL REFERENCES exams(id) ON DELETE RESTRICT,
    title          VARCHAR(255) NOT NULL,
    description    TEXT NOT NULL DEFAULT '',
    thumbnail      TEXT NOT NULL DEFAULT '',
    is_free_trial  BOOLEAN NOT NULL DEFAULT false,
    display_order  INTEGER NOT NULL DEFAULT 0,
    is_active      BOOLEAN NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_batches_exam_id            ON batches (exam_id);
CREATE INDEX idx_batches_exam_display_order ON batches (exam_id, display_order);
CREATE INDEX idx_batches_is_active          ON batches (is_active) WHERE is_active = true;

CREATE UNIQUE INDEX uq_batches_free_trial_per_exam
    ON batches (exam_id)
    WHERE is_free_trial = true;

CREATE TRIGGER trg_batches_updated_at
    BEFORE UPDATE ON batches
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- SUBJECTS
-- =====================================================================
CREATE TABLE subjects (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id       UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    name           VARCHAR(255) NOT NULL,
    icon           TEXT NOT NULL DEFAULT '',
    display_order  INTEGER NOT NULL DEFAULT 0,
    is_active      BOOLEAN NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_subjects_batch_id            ON subjects (batch_id);
CREATE INDEX idx_subjects_batch_display_order ON subjects (batch_id, display_order);
CREATE INDEX idx_subjects_is_active           ON subjects (is_active) WHERE is_active = true;

CREATE TRIGGER trg_subjects_updated_at
    BEFORE UPDATE ON subjects
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- CHAPTERS
-- =====================================================================
CREATE TABLE chapters (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id     UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    title          VARCHAR(255) NOT NULL,
    display_order  INTEGER NOT NULL DEFAULT 0,
    is_active      BOOLEAN NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_chapters_subject_id            ON chapters (subject_id);
CREATE INDEX idx_chapters_subject_display_order ON chapters (subject_id, display_order);
CREATE INDEX idx_chapters_is_active             ON chapters (is_active) WHERE is_active = true;

CREATE TRIGGER trg_chapters_updated_at
    BEFORE UPDATE ON chapters
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- LECTURES
-- =====================================================================
CREATE TABLE lectures (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id        UUID NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
    title             VARCHAR(255) NOT NULL,
    video_url         TEXT NOT NULL DEFAULT '',
    duration_seconds  INTEGER NOT NULL DEFAULT 0,
    display_order     INTEGER NOT NULL DEFAULT 0,
    is_active         BOOLEAN NOT NULL DEFAULT true,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_lectures_chapter_id            ON lectures (chapter_id);
CREATE INDEX idx_lectures_chapter_display_order ON lectures (chapter_id, display_order);
CREATE INDEX idx_lectures_is_active             ON lectures (is_active) WHERE is_active = true;

CREATE TRIGGER trg_lectures_updated_at
    BEFORE UPDATE ON lectures
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- FREE TRIAL ACCESS VIEWS
-- =====================================================================

CREATE OR REPLACE VIEW v_chapter_access AS
SELECT
    c.id              AS chapter_id,
    c.subject_id,
    s.batch_id,
    b.is_free_trial   AS batch_is_free_trial,
    ROW_NUMBER() OVER (
        PARTITION BY s.batch_id
        ORDER BY s.display_order, c.display_order
    ) AS chapter_rank_in_batch,
    (b.is_free_trial AND ROW_NUMBER() OVER (
        PARTITION BY s.batch_id
        ORDER BY s.display_order, c.display_order
    ) <= 5) AS is_free_preview
FROM chapters c
JOIN subjects s ON s.id = c.subject_id
JOIN batches  b ON b.id = s.batch_id
WHERE c.is_active = true AND s.is_active = true AND b.is_active = true;

CREATE OR REPLACE VIEW v_lecture_access AS
SELECT
    l.id              AS lecture_id,
    l.chapter_id,
    s.batch_id,
    b.is_free_trial   AS batch_is_free_trial,
    ROW_NUMBER() OVER (
        PARTITION BY s.batch_id
        ORDER BY s.display_order, c.display_order, l.display_order
    ) AS lecture_rank_in_batch,
    (b.is_free_trial AND ROW_NUMBER() OVER (
        PARTITION BY s.batch_id
        ORDER BY s.display_order, c.display_order, l.display_order
    ) <= 10) AS is_free_preview
FROM lectures l
JOIN chapters c ON c.id = l.chapter_id
JOIN subjects s ON s.id = c.subject_id
JOIN batches  b ON b.id = s.batch_id
WHERE l.is_active = true AND c.is_active = true
  AND s.is_active = true AND b.is_active = true;

COMMIT;
