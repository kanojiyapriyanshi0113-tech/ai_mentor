-- =====================================================================
-- Migration: 005_create_course_management_tables (DOWN)
-- =====================================================================

BEGIN;

DROP VIEW IF EXISTS v_lecture_access;
DROP VIEW IF EXISTS v_chapter_access;

DROP TRIGGER IF EXISTS trg_lectures_updated_at ON lectures;
DROP TRIGGER IF EXISTS trg_chapters_updated_at ON chapters;
DROP TRIGGER IF EXISTS trg_subjects_updated_at ON subjects;
DROP TRIGGER IF EXISTS trg_batches_updated_at ON batches;

DROP TABLE IF EXISTS lectures;
DROP TABLE IF EXISTS chapters;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS batches;

-- Not dropping set_updated_at() since other migrations/tables may reuse it.
-- Drop manually if confirmed unused elsewhere:
-- DROP FUNCTION IF EXISTS set_updated_at();

COMMIT;
