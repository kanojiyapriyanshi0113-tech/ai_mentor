-- +migrate Up
CREATE TABLE subscription_features (
    id            SERIAL PRIMARY KEY,
    plan_id       INT NOT NULL REFERENCES plans (id) ON DELETE CASCADE,
    feature_key   VARCHAR(50) NOT NULL,
    feature_limit INT NOT NULL DEFAULT 0,
    UNIQUE (plan_id, feature_key)
);
CREATE INDEX idx_subscription_features_plan_id ON subscription_features (plan_id);

-- feature_limit: -1 = unlimited, 0 = not allowed, N = numeric cap

INSERT INTO subscription_features (plan_id, feature_key, feature_limit)
SELECT id, f.feature_key, f.feature_limit FROM plans, (VALUES
    ('max_exams', 1), ('max_batches', 1), ('max_chapters', 5),
    ('max_lectures', 10), ('max_notes', 5), ('max_mock_tests', 5),
    ('pyq_limit', -1), ('ai_chat_daily_limit', 20),
    ('has_streak', 1), ('has_progress_tracking', 1), ('has_reminders', 1)
) AS f(feature_key, feature_limit) WHERE plans.code = 'free_trial';

INSERT INTO subscription_features (plan_id, feature_key, feature_limit)
SELECT id, f.feature_key, f.feature_limit FROM plans, (VALUES
    ('max_exams', 3), ('max_batches', 3), ('max_chapters', -1),
    ('max_lectures', -1), ('max_notes', -1), ('max_mock_tests', 30),
    ('pyq_limit', -1), ('ai_chat_daily_limit', 100),
    ('has_streak', 1), ('has_progress_tracking', 1), ('has_reminders', 1)
) AS f(feature_key, feature_limit) WHERE plans.code = 'pro';

INSERT INTO subscription_features (plan_id, feature_key, feature_limit)
SELECT id, f.feature_key, f.feature_limit FROM plans, (VALUES
    ('max_exams', 5), ('max_batches', 5), ('max_chapters', -1),
    ('max_lectures', -1), ('max_notes', -1), ('max_mock_tests', 100),
    ('pyq_limit', -1), ('ai_chat_daily_limit', 300),
    ('has_streak', 1), ('has_progress_tracking', 1), ('has_reminders', 1)
) AS f(feature_key, feature_limit) WHERE plans.code = 'ultra';

INSERT INTO subscription_features (plan_id, feature_key, feature_limit)
SELECT id, f.feature_key, f.feature_limit FROM plans, (VALUES
    ('max_exams', -1), ('max_batches', -1), ('max_chapters', -1),
    ('max_lectures', -1), ('max_notes', -1), ('max_mock_tests', -1),
    ('pyq_limit', -1), ('ai_chat_daily_limit', -1),
    ('has_streak', 1), ('has_progress_tracking', 1), ('has_reminders', 1)
) AS f(feature_key, feature_limit) WHERE plans.code = 'ultra_max';