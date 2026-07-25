BEGIN;

DELETE FROM subscription_features WHERE feature_key IN (
  'has_live_classes','has_ai_planner','has_ai_notes','has_document_upload',
  'has_image_doubt_upload','has_performance_analytics','has_personalized_recommendations',
  'has_priority_content_updates','has_priority_support','has_early_access','has_premium_ai_suite'
);

DELETE FROM subscription_features WHERE plan_id = 4 AND feature_key = 'has_progress_tracking';

UPDATE subscription_features SET feature_limit = 10 WHERE plan_id = 1 AND feature_key = 'max_lectures';

UPDATE subscription_features SET feature_limit = 3  WHERE plan_id = 2 AND feature_key = 'max_exams';
UPDATE subscription_features SET feature_limit = 3  WHERE plan_id = 2 AND feature_key = 'max_batches';
UPDATE subscription_features SET feature_limit = -1 WHERE plan_id = 2 AND feature_key = 'max_chapters';
UPDATE subscription_features SET feature_limit = -1 WHERE plan_id = 2 AND feature_key = 'max_lectures';
UPDATE subscription_features SET feature_limit = -1 WHERE plan_id = 2 AND feature_key = 'max_notes';
UPDATE subscription_features SET feature_limit = 30 WHERE plan_id = 2 AND feature_key = 'max_mock_tests';

UPDATE subscription_features SET feature_limit = 5   WHERE plan_id = 3 AND feature_key = 'max_exams';
UPDATE subscription_features SET feature_limit = -1  WHERE plan_id = 3 AND feature_key = 'max_lectures';
UPDATE subscription_features SET feature_limit = -1  WHERE plan_id = 3 AND feature_key = 'max_notes';
UPDATE subscription_features SET feature_limit = 100 WHERE plan_id = 3 AND feature_key = 'max_mock_tests';
UPDATE subscription_features SET feature_limit = 300 WHERE plan_id = 3 AND feature_key = 'ai_chat_daily_limit';

COMMIT;
