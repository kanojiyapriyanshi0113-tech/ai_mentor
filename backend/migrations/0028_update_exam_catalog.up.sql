-- =====================================================================
-- Migration: 007_update_exam_catalog
-- Purpose:   Remove JEE/NEET (school-level) and replace with
--            graduation-level competitive exams, grouped by category.
-- NOTE: batches.exam_id has ON DELETE CASCADE, so any batches (and
--       their subjects/chapters/lectures) linked to JEE/NEET are
--       permanently removed by this migration. This is intentional
--       per explicit confirmation.
-- =====================================================================

BEGIN;

ALTER TABLE exams ADD COLUMN IF NOT EXISTS category VARCHAR(100) NOT NULL DEFAULT '';

-- Defensive: clear any user selections pointing at exams about to be
-- removed, in case user_exams.exam_id does not itself cascade.
DELETE FROM user_exams WHERE exam_id IN (SELECT id FROM exams WHERE code IN ('NEET', 'JEE'));

-- Remove NEET/JEE (cascades batches -> subjects -> chapters -> lectures)
DELETE FROM exams WHERE code IN ('NEET', 'JEE');

-- Categorize the graduation-level exams that already existed
UPDATE exams SET category = 'Government Jobs'
WHERE code IN ('UPSC', 'SSC', 'BANKING', 'RAILWAY', 'STATE_PSC');

-- New graduation-level competitive exams
INSERT INTO exams (id, code, name, category) VALUES
    (10, 'CAT',       'CAT',       'Higher Education'),
    (11, 'GATE',      'GATE',      'Higher Education'),
    (12, 'UGC_NET',   'UGC NET',   'Higher Education'),
    (13, 'CUET_PG',   'CUET PG',   'Higher Education'),
    (14, 'CTET',      'CTET',      'Teaching'),
    (15, 'REET',      'REET',      'Teaching'),
    (16, 'KVS',       'KVS',       'Teaching'),
    (17, 'CDS',       'CDS',       'Defence'),
    (18, 'CAPF',      'CAPF',      'Defence'),
    (19, 'AFCAT',     'AFCAT',     'Defence'),
    (20, 'JUDICIARY', 'Judiciary', 'Law'),
    (21, 'CLAT_PG',   'CLAT PG',   'Law')
ON CONFLICT (id) DO NOTHING;

-- Keep the id sequence (if exams.id is serial/identity) ahead of our
-- explicit inserts so future auto-generated inserts don't collide.
DO $$
DECLARE
    seq_name text := pg_get_serial_sequence('exams', 'id');
BEGIN
    IF seq_name IS NOT NULL THEN
        PERFORM setval(seq_name, (SELECT MAX(id) FROM exams));
    END IF;
END $$;

COMMIT;
