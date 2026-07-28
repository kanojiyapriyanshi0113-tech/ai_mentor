DROP TABLE IF EXISTS teacher_payouts;
DROP TABLE IF EXISTS teacher_commissions;
DROP TABLE IF EXISTS assignments;
ALTER TABLE batches DROP COLUMN IF EXISTS teacher_id;
DROP TABLE IF EXISTS teacher_applications;