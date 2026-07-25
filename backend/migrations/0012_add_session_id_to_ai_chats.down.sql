-- +migrate Down
DROP INDEX IF EXISTS idx_ai_chats_session_id;
ALTER TABLE ai_chats DROP COLUMN IF EXISTS session_id;