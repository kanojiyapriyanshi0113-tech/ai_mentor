-- +migrate Down
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS refunds;
DROP TABLE IF EXISTS certificates;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS student_progress;
DROP TABLE IF EXISTS user_notifications;
DROP TABLE IF EXISTS assignment_submissions;
DROP TABLE IF EXISTS teacher_earnings;
DROP TABLE IF EXISTS teacher_profiles;
