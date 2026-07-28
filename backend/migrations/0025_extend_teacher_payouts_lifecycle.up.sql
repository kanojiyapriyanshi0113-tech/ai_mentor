-- +migrate Up
-- Teacher Payout module: extend the existing teacher_payouts table (added in
-- 0022 for the Earnings module, where every payout was recorded already
-- "completed") with a pending -> paid lifecycle so an admin can create a
-- payout record first and confirm it separately via Mark Paid.
ALTER TABLE teacher_payouts DROP CONSTRAINT IF EXISTS teacher_payouts_status_check;
ALTER TABLE teacher_payouts ADD CONSTRAINT teacher_payouts_status_check
    CHECK (status IN ('completed', 'pending', 'paid'));

ALTER TABLE teacher_payouts ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE teacher_payouts ADD COLUMN IF NOT EXISTS paid_at TIMESTAMPTZ;
ALTER TABLE teacher_payouts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_teacher_payouts_status ON teacher_payouts (status);
