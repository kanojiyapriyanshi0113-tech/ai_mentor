-- Run this AFTER registering these emails via the app's Register screen
-- (registration always creates role='student'; this script promotes two of them).
--
-- Usage:
--   psql "<your DATABASE_URL>" -f seed_test_roles.sql
-- or paste the statements directly into pgAdmin / DBeaver / psql shell.

UPDATE users SET role = 'teacher' WHERE email = 'teacher@aimentor.com';
UPDATE users SET role = 'admin'   WHERE email = 'admin@aimentor.com';
-- student@aimentor.com is left as role='student' (the default) on purpose.

-- Verify the result:
SELECT email, role FROM users
WHERE email IN ('student@aimentor.com', 'teacher@aimentor.com', 'admin@aimentor.com')
ORDER BY role;
