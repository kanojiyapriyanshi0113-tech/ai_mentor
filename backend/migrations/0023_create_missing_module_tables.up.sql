-- +migrate Up
-- Fills gaps left by existing modules (teacher_applications, teacher_payouts,
-- live_classes, assignments, notifications, lecture progress, coupons,
-- payments, app_settings, banners already exist — see 0001-0022).
-- Every table below is new. All use UUID PKs, FK constraints, indexes,
-- created_at/updated_at, and a deleted_at column for soft delete.

-- ============================================================
-- 1. Teachers: extended profile beyond the bare users/applications rows.
-- ============================================================
CREATE TABLE teacher_profiles (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    application_id    UUID REFERENCES teacher_applications (id) ON DELETE SET NULL,
    headline          VARCHAR(200) NOT NULL DEFAULT '',
    bio               TEXT NOT NULL DEFAULT '',
    qualification     VARCHAR(200) NOT NULL DEFAULT '',
    experience_years  INTEGER NOT NULL DEFAULT 0,
    exam_expertise    VARCHAR(300) NOT NULL DEFAULT '',
    subjects          VARCHAR(300) NOT NULL DEFAULT '',
    photo_url         VARCHAR(500) NOT NULL DEFAULT '',
    rating            NUMERIC(3, 2) NOT NULL DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
    total_ratings     INTEGER NOT NULL DEFAULT 0,
    status            VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active', 'inactive', 'suspended')),
    approved_at       TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at        TIMESTAMPTZ
);
CREATE INDEX idx_teacher_profiles_status ON teacher_profiles (status) WHERE deleted_at IS NULL;
CREATE INDEX idx_teacher_profiles_deleted_at ON teacher_profiles (deleted_at) WHERE deleted_at IS NULL;

CREATE TRIGGER trg_teacher_profiles_updated_at
    BEFORE UPDATE ON teacher_profiles
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 2. Teacher Earnings: per-transaction earning ledger. Distinct from
--    teacher_commissions (the rate) and teacher_payouts (money paid out).
-- ============================================================
CREATE TABLE teacher_earnings (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id          UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    student_id          UUID REFERENCES users (id) ON DELETE SET NULL,
    payment_id          UUID REFERENCES payments (id) ON DELETE SET NULL,
    payout_id           UUID REFERENCES teacher_payouts (id) ON DELETE SET NULL,
    source              VARCHAR(20) NOT NULL DEFAULT 'subscription'
                        CHECK (source IN ('subscription', 'course_sale', 'bonus', 'adjustment')),
    gross_amount_paise  INTEGER NOT NULL,
    commission_percent  INTEGER NOT NULL CHECK (commission_percent BETWEEN 0 AND 100),
    earned_amount_paise INTEGER NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'payable', 'paid', 'reversed')),
    earned_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);
CREATE INDEX idx_teacher_earnings_teacher_id ON teacher_earnings (teacher_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_teacher_earnings_status ON teacher_earnings (status) WHERE deleted_at IS NULL;
CREATE INDEX idx_teacher_earnings_payout_id ON teacher_earnings (payout_id);
CREATE INDEX idx_teacher_earnings_earned_at ON teacher_earnings (earned_at);

CREATE TRIGGER trg_teacher_earnings_updated_at
    BEFORE UPDATE ON teacher_earnings
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- Assignments already exist; this adds student submissions against them.
-- ============================================================
CREATE TABLE assignment_submissions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id   UUID NOT NULL REFERENCES assignments (id) ON DELETE CASCADE,
    student_id      UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    file_url        VARCHAR(500) NOT NULL DEFAULT '',
    submission_text TEXT NOT NULL DEFAULT '',
    marks_obtained  INTEGER,
    feedback        TEXT NOT NULL DEFAULT '',
    status          VARCHAR(20) NOT NULL DEFAULT 'submitted'
                        CHECK (status IN ('submitted', 'late', 'graded', 'resubmit_requested')),
    submitted_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    graded_at       TIMESTAMPTZ,
    graded_by       UUID REFERENCES users (id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ,
    UNIQUE (assignment_id, student_id)
);
CREATE INDEX idx_assignment_submissions_assignment_id ON assignment_submissions (assignment_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_assignment_submissions_student_id ON assignment_submissions (student_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_assignment_submissions_status ON assignment_submissions (status);

CREATE TRIGGER trg_assignment_submissions_updated_at
    BEFORE UPDATE ON assignment_submissions
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- Notifications already exist as batch broadcasts (sender -> whole batch).
-- This adds the recipient-scoped, read-tracked feed the student/teacher/
-- admin notification screens need (direct messages, system/payment/
-- application alerts, and per-user read state for batch broadcasts).
-- ============================================================
CREATE TABLE user_notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id    UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    sender_id       UUID REFERENCES users (id) ON DELETE SET NULL,
    notification_id UUID REFERENCES notifications (id) ON DELETE CASCADE,
    type            VARCHAR(30) NOT NULL DEFAULT 'general'
                        CHECK (type IN ('general', 'batch', 'payment', 'assignment',
                                         'live_class', 'application', 'system')),
    title           VARCHAR(200) NOT NULL,
    message         TEXT NOT NULL,
    is_read         BOOLEAN NOT NULL DEFAULT false,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ
);
CREATE INDEX idx_user_notifications_recipient_id ON user_notifications (recipient_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_notifications_recipient_unread ON user_notifications (recipient_id, is_read) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_notifications_notification_id ON user_notifications (notification_id);

CREATE TRIGGER trg_user_notifications_updated_at
    BEFORE UPDATE ON user_notifications
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 8. Student Progress: aggregate rollup per student/batch(/subject).
--    Lecture-level completions already exist (user_lecture_progress);
--    this is the summarized view the progress dashboards read.
-- ============================================================
CREATE TABLE student_progress (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id         UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    batch_id           UUID NOT NULL REFERENCES batches (id) ON DELETE CASCADE,
    subject_id         UUID REFERENCES subjects (id) ON DELETE CASCADE,
    total_lectures     INTEGER NOT NULL DEFAULT 0,
    completed_lectures INTEGER NOT NULL DEFAULT 0,
    progress_percent   NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    streak_days        INTEGER NOT NULL DEFAULT 0,
    last_activity_at   TIMESTAMPTZ,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at         TIMESTAMPTZ
);
-- One row per student/batch/subject, and a separate one per student/batch
-- overall (subject_id NULL) — Postgres treats NULLs as distinct so this
-- needs two partial unique indexes rather than one plain UNIQUE.
CREATE UNIQUE INDEX idx_student_progress_subject_unique
    ON student_progress (student_id, batch_id, subject_id) WHERE subject_id IS NOT NULL;
CREATE UNIQUE INDEX idx_student_progress_batch_unique
    ON student_progress (student_id, batch_id) WHERE subject_id IS NULL;
CREATE INDEX idx_student_progress_student_id ON student_progress (student_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_student_progress_batch_id ON student_progress (batch_id) WHERE deleted_at IS NULL;

CREATE TRIGGER trg_student_progress_updated_at
    BEFORE UPDATE ON student_progress
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 9. Attendance: per-student record for each live class.
-- ============================================================
CREATE TABLE attendance (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    live_class_id    UUID NOT NULL REFERENCES live_classes (id) ON DELETE CASCADE,
    student_id       UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    status           VARCHAR(20) NOT NULL DEFAULT 'present'
                        CHECK (status IN ('present', 'absent', 'late', 'excused')),
    joined_at        TIMESTAMPTZ,
    left_at          TIMESTAMPTZ,
    duration_minutes INTEGER NOT NULL DEFAULT 0,
    marked_by        UUID REFERENCES users (id) ON DELETE SET NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at       TIMESTAMPTZ,
    UNIQUE (live_class_id, student_id)
);
CREATE INDEX idx_attendance_live_class_id ON attendance (live_class_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_attendance_student_id ON attendance (student_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_attendance_status ON attendance (status);

CREATE TRIGGER trg_attendance_updated_at
    BEFORE UPDATE ON attendance
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 10. Certificates.
-- ============================================================
CREATE TABLE certificates (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id         UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    batch_id           UUID REFERENCES batches (id) ON DELETE SET NULL,
    certificate_number VARCHAR(50) NOT NULL UNIQUE,
    title              VARCHAR(200) NOT NULL,
    file_url           VARCHAR(500) NOT NULL DEFAULT '',
    status             VARCHAR(20) NOT NULL DEFAULT 'issued'
                        CHECK (status IN ('issued', 'revoked')),
    issued_by          UUID REFERENCES users (id) ON DELETE SET NULL,
    issued_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at         TIMESTAMPTZ,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at         TIMESTAMPTZ
);
CREATE INDEX idx_certificates_student_id ON certificates (student_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_certificates_batch_id ON certificates (batch_id);
CREATE INDEX idx_certificates_status ON certificates (status);

CREATE TRIGGER trg_certificates_updated_at
    BEFORE UPDATE ON certificates
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- Refunds: payments already exist with a 'refunded' status + refunded_at;
-- this is the underlying request/approval ledger behind that status.
-- ============================================================
CREATE TABLE refunds (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id   UUID NOT NULL REFERENCES payments (id) ON DELETE CASCADE,
    user_id      UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    amount_paise INTEGER NOT NULL,
    reason       VARCHAR(300) NOT NULL DEFAULT '',
    status       VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'approved', 'rejected', 'processed')),
    gateway_ref  VARCHAR(100) NOT NULL DEFAULT '',
    processed_by UUID REFERENCES users (id) ON DELETE SET NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_at TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ
);
CREATE INDEX idx_refunds_payment_id ON refunds (payment_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_refunds_user_id ON refunds (user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_refunds_status ON refunds (status);

CREATE TRIGGER trg_refunds_updated_at
    BEFORE UPDATE ON refunds
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- 14. Reports: admin-generated/exported report jobs.
-- ============================================================
CREATE TABLE reports (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type         VARCHAR(30) NOT NULL
                        CHECK (type IN ('revenue', 'students', 'courses', 'teachers', 'custom')),
    title        VARCHAR(200) NOT NULL,
    filters      JSONB NOT NULL DEFAULT '{}'::jsonb,
    file_url     VARCHAR(500) NOT NULL DEFAULT '',
    status       VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    generated_by UUID REFERENCES users (id) ON DELETE SET NULL,
    generated_at TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ
);
CREATE INDEX idx_reports_type ON reports (type) WHERE deleted_at IS NULL;
CREATE INDEX idx_reports_status ON reports (status);
CREATE INDEX idx_reports_generated_by ON reports (generated_by);

CREATE TRIGGER trg_reports_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
