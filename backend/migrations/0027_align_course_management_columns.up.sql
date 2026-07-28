-- =====================================================================
-- Migration: 006_align_course_management_columns
-- Purpose:   batches/subjects/chapters/lectures already exist with a
--            partial schema. This migration ADDS the missing columns
--            (display_order, is_active, created_at, updated_at,
--            is_free_trial) instead of creating tables from scratch.
-- Idempotent: safe to re-run.
-- =====================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
ALTER TABLE batches ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE batches ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE batches ADD COLUMN IF NOT EXISTS is_free_trial BOOLEAN NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_batches_exam_display_order ON batches (exam_id, display_order);

-- Only one batch per exam can be flagged as the free-trial batch
CREATE UNIQUE INDEX IF NOT EXISTS uq_batches_free_trial_per_exam
    ON batches (exam_id)
    WHERE is_free_trial = true;

-- Trigger already existed but was broken (no updated_at column to write to).
-- Recreated now that the column exists.
DROP TRIGGER IF EXISTS trg_batches_updated_at ON batches;
CREATE TRIGGER trg_batches_updated_at
    BEFORE UPDATE ON batches
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- SUBJECTS
-- =====================================================================
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE subjects ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_subjects_is_active ON subjects (is_active) WHERE is_active = true;

DROP TRIGGER IF EXISTS trg_subjects_updated_at ON subjects;
CREATE TRIGGER trg_subjects_updated_at
    BEFORE UPDATE ON subjects
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- CHAPTERS
-- =====================================================================
ALTER TABLE chapters ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE chapters ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE chapters ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_chapters_is_active ON chapters (is_active) WHERE is_active = true;

DROP TRIGGER IF EXISTS trg_chapters_updated_at ON chapters;
CREATE TRIGGER trg_chapters_updated_at
    BEFORE UPDATE ON chapters
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- LECTURES
-- =====================================================================
ALTER TABLE lectures ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE lectures ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now();
ALTER TABLE lectures ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_lectures_is_active ON lectures (is_active) WHERE is_active = true;

DROP TRIGGER IF EXISTS trg_lectures_updated_at ON lectures;
CREATE TRIGGER trg_lectures_updated_at
    BEFORE UPDATE ON lectures
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =====================================================================
-- FREE TRIAL ACCESS VIEWS
-- Rules: within the single is_free_trial batch ->
--   first 5 chapters overall (by subject.display_order, chapter.display_order)
--   first 10 lectures overall (by subject/chapter/lecture display_order)
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
