-- +migrate Up
ALTER TABLE ai_chats ADD COLUMN session_id UUID REFERENCES chat_sessions (id) ON DELETE CASCADE;

CREATE INDEX idx_ai_chats_session_id ON ai_chats (session_id, created_at);