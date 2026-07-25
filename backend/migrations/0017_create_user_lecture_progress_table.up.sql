-- +migrate Up
CREATE TABLE user_lecture_progress (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    lecture_id   UUID NOT NULL REFERENCES lectures (id) ON DELETE CASCADE,
    chapter_id   UUID NOT NULL REFERENCES chapters (id) ON DELETE CASCADE,
    subject_id   UUID NOT NULL REFERENCES subjects (id) ON DELETE CASCADE,
    batch_id     UUID NOT NULL REFERENCES batches (id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, lecture_id)
);

CREATE INDEX idx_user_lecture_progress_user_batch ON user_lecture_progress (user_id, batch_id);
CREATE INDEX idx_user_lecture_progress_user_chapter ON user_lecture_progress (user_id, chapter_id);
CREATE INDEX idx_user_lecture_progress_user_completed_at ON user_lecture_progress (user_id, completed_at DESC);
