-- Become a Teacher: student-submitted applications reviewed by admin.
CREATE TABLE IF NOT EXISTS teacher_applications (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name         VARCHAR(200) NOT NULL,
    email             VARCHAR(200) NOT NULL,
    phone             VARCHAR(30) NOT NULL,
    qualification     VARCHAR(200) NOT NULL DEFAULT '',
    experience_years  INTEGER NOT NULL DEFAULT 0,
    exam_expertise    VARCHAR(300) NOT NULL DEFAULT '',
    subjects          VARCHAR(300) NOT NULL DEFAULT '',
    about             TEXT NOT NULL DEFAULT '',
    resume_url        VARCHAR(500) NOT NULL DEFAULT '',
    degree_url        VARCHAR(500) NOT NULL DEFAULT '',
    govt_id_url       VARCHAR(500) NOT NULL DEFAULT '',
    photo_url         VARCHAR(500) NOT NULL DEFAULT '',
    demo_video_url    VARCHAR(500) NOT NULL DEFAULT '',
    expected_salary   INTEGER NOT NULL DEFAULT 0,
    status            VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','approved','rejected','changes_requested')),
    admin_note        TEXT NOT NULL DEFAULT '',
    reviewed_by       UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at       TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_teacher_applications_user_id ON teacher_applications (user_id);
CREATE INDEX IF NOT EXISTS idx_teacher_applications_status ON teacher_applications (status);
-- One active (pending/changes_requested) application per user at a time.
CREATE UNIQUE INDEX IF NOT EXISTS idx_teacher_applications_one_open_per_user
    ON teacher_applications (user_id)
    WHERE status IN ('pending','changes_requested');

-- Content ownership so "My Batches" / "My Students" can be scoped per teacher.
ALTER TABLE batches ADD COLUMN IF NOT EXISTS teacher_id UUID REFERENCES users(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_batches_teacher_id ON batches (teacher_id);

-- Assignments (teacher-created, batch scoped), mirroring the pyqs/mock_tests shape.
CREATE TABLE IF NOT EXISTS assignments (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id      UUID NOT NULL REFERENCES batches(id) ON DELETE CASCADE,
    title         VARCHAR(200) NOT NULL,
    description   TEXT NOT NULL DEFAULT '',
    file_url      VARCHAR(500) NOT NULL DEFAULT '',
    due_at        TIMESTAMPTZ,
    max_marks     INTEGER NOT NULL DEFAULT 0,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_assignments_batch_id ON assignments (batch_id);
CREATE INDEX IF NOT EXISTS idx_assignments_is_active ON assignments (is_active) WHERE is_active = true;

-- Revenue-share earnings: per-teacher commission rate + payout ledger.
CREATE TABLE IF NOT EXISTS teacher_commissions (
    teacher_id        UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    commission_percent INTEGER NOT NULL DEFAULT 50 CHECK (commission_percent BETWEEN 0 AND 100),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS teacher_payouts (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount_paise  INTEGER NOT NULL,
    note          VARCHAR(300) NOT NULL DEFAULT '',
    status        VARCHAR(20) NOT NULL DEFAULT 'completed' CHECK (status IN ('completed')),
    paid_by       UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_teacher_payouts_teacher_id ON teacher_payouts (teacher_id);