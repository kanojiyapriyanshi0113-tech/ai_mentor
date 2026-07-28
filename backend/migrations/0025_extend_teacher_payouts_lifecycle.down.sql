-- +migrate Down
DROP INDEX IF EXISTS idx_teacher_payouts_status;

ALTER TABLE teacher_payouts DROP COLUMN IF EXISTS updated_at;
ALTER TABLE teacher_payouts DROP COLUMN IF EXISTS paid_at;
ALTER TABLE teacher_payouts DROP COLUMN IF EXISTS created_by;

ALTER TABLE teacher_payouts DROP CONSTRAINT IF EXISTS teacher_payouts_status_check;
ALTER TABLE teacher_payouts ADD CONSTRAINT teacher_payouts_status_check
    CHECK (status IN ('completed'));
