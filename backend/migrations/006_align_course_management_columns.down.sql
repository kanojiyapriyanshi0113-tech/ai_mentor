-- =====================================================================
-- Migration: 006_align_course_management_columns (DOWN)
-- Only reverses what THIS migration added. Does not drop batches/
-- subjects/chapters triggers that pre-existed before this migration.
-- =====================================================================

BEGIN;

DROP VIEW IF EXISTS v_lecture_access;
DROP VIEW IF EXISTS v_chapter_access;

DROP TRIGGER IF EXISTS trg_lectures_updated_at ON lectures;

ALTER TABLE lectures DROP COLUMN IF EXISTS updated_at;
ALTER TABLE lectures DROP COLUMN IF EXISTS created_at;
ALTER TABLE lectures DROP COLUMN IF EXISTS is_active;

ALTER TABLE chapters DROP COLUMN IF EXISTS updated_at;
ALTER TABLE chapters DROP COLUMN IF EXISTS created_at;
ALTER TABLE chapters DROP COLUMN IF EXISTS is_active;

ALTER TABLE subjects DROP COLUMN IF EXISTS updated_at;
ALTER TABLE subjects DROP COLUMN IF EXISTS created_at;
ALTER TABLE subjects DROP COLUMN IF EXISTS is_active;

DROP INDEX IF EXISTS uq_batches_free_trial_per_exam;
DROP INDEX IF EXISTS idx_batches_exam_display_order;

ALTER TABLE batches DROP COLUMN IF EXISTS is_free_trial;
ALTER TABLE batches DROP COLUMN IF EXISTS updated_at;
ALTER TABLE batches DROP COLUMN IF EXISTS display_order;

-- Note: this will make the pre-existing trg_batches_updated_at /
-- trg_subjects_updated_at / trg_chapters_updated_at triggers reference
-- a nonexistent column again, reintroducing the original bug. If you
-- want that trigger removed too, drop it manually.

COMMIT;
