-- +migrate Up
CREATE TABLE ai_chats (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role        VARCHAR(10) NOT NULL CHECK (role IN ('user', 'assistant')),
    message     TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ai_chats_user_id ON ai_chats (user_id);
CREATE INDEX idx_ai_chats_user_id_created_at ON ai_chats (user_id, created_at);
