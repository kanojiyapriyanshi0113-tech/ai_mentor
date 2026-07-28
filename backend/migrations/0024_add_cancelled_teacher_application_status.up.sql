-- +migrate Up
-- Allow a student to withdraw their own "Become a Teacher" application.
ALTER TABLE teacher_applications DROP CONSTRAINT IF EXISTS teacher_applications_status_check;
ALTER TABLE teacher_applications ADD CONSTRAINT teacher_applications_status_check
    CHECK (status IN ('pending', 'approved', 'rejected', 'changes_requested', 'cancelled'));
