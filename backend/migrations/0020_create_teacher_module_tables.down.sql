DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS live_classes;
DROP TABLE IF EXISTS pyqs;
DROP TABLE IF EXISTS mock_tests;
DROP TABLE IF EXISTS pdfs;
DROP INDEX IF EXISTS idx_batches_is_published;
ALTER TABLE batches DROP COLUMN IF EXISTS is_published;