-- =====================================================================
-- Migration: 007_update_exam_catalog (DOWN)
-- NOTE: This restores the exam rows only. Batches/subjects/chapters/
--       lectures that were CASCADE-deleted with JEE/NEET in the up
--       migration cannot be restored here -- that data is gone.
-- =====================================================================

BEGIN;

DELETE FROM exams WHERE code IN (
    'CAT','GATE','UGC_NET','CUET_PG','CTET','REET','KVS',
    'CDS','CAPF','AFCAT','JUDICIARY','CLAT_PG'
);

INSERT INTO exams (id, code, name, category) VALUES
    (5, 'NEET', 'NEET', ''),
    (6, 'JEE',  'JEE',  '')
ON CONFLICT (id) DO NOTHING;

ALTER TABLE exams DROP COLUMN IF EXISTS category;

COMMIT;
