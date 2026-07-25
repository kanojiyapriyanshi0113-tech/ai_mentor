# Run this from: C:\Users\ABC\Desktop\AI_Mentor\backend
# Usage:  .\fix_migration_0018.ps1

$ErrorActionPreference = "Stop"

$migrationContent = @'
BEGIN;

-- Free Trial: video lecture cap 10 -> 5
UPDATE subscription_features SET feature_limit = 5 WHERE plan_id = 1 AND feature_key = 'max_lectures';

-- Pro: all exams, 5 batches, 20 chapters/lectures/notes/mocks
UPDATE subscription_features SET feature_limit = -1 WHERE plan_id = 2 AND feature_key = 'max_exams';
UPDATE subscription_features SET feature_limit = 5  WHERE plan_id = 2 AND feature_key = 'max_batches';
UPDATE subscription_features SET feature_limit = 20 WHERE plan_id = 2 AND feature_key = 'max_chapters';
UPDATE subscription_features SET feature_limit = 20 WHERE plan_id = 2 AND feature_key = 'max_lectures';
UPDATE subscription_features SET feature_limit = 20 WHERE plan_id = 2 AND feature_key = 'max_notes';
UPDATE subscription_features SET feature_limit = 20 WHERE plan_id = 2 AND feature_key = 'max_mock_tests';

-- Ultra: all exams, 50 lectures/notes/mocks, AI chat 500/day
UPDATE subscription_features SET feature_limit = -1  WHERE plan_id = 3 AND feature_key = 'max_exams';
UPDATE subscription_features SET feature_limit = 50  WHERE plan_id = 3 AND feature_key = 'max_lectures';
UPDATE subscription_features SET feature_limit = 50  WHERE plan_id = 3 AND feature_key = 'max_notes';
UPDATE subscription_features SET feature_limit = 50  WHERE plan_id = 3 AND feature_key = 'max_mock_tests';
UPDATE subscription_features SET feature_limit = 500 WHERE plan_id = 3 AND feature_key = 'ai_chat_daily_limit';

-- Fix pre-existing gap: Ultra Max was missing has_progress_tracking
INSERT INTO subscription_features (plan_id, feature_key, feature_limit)
VALUES (4, 'has_progress_tracking', 1)
ON CONFLICT (plan_id, feature_key) DO UPDATE SET feature_limit = EXCLUDED.feature_limit;

-- New boolean feature flags (0 = locked, 1 = enabled)
INSERT INTO subscription_features (plan_id, feature_key, feature_limit) VALUES
  (1, 'has_live_classes', 0), (2, 'has_live_classes', 0), (3, 'has_live_classes', 1), (4, 'has_live_classes', 1),
  (1, 'has_ai_planner', 0), (2, 'has_ai_planner', 0), (3, 'has_ai_planner', 1), (4, 'has_ai_planner', 1),
  (1, 'has_ai_notes', 0), (2, 'has_ai_notes', 0), (3, 'has_ai_notes', 1), (4, 'has_ai_notes', 1),
  (1, 'has_document_upload', 0), (2, 'has_document_upload', 1), (3, 'has_document_upload', 1), (4, 'has_document_upload', 1),
  (1, 'has_image_doubt_upload', 0), (2, 'has_image_doubt_upload', 1), (3, 'has_image_doubt_upload', 1), (4, 'has_image_doubt_upload', 1),
  (1, 'has_performance_analytics', 0), (2, 'has_performance_analytics', 1), (3, 'has_performance_analytics', 1), (4, 'has_performance_analytics', 1),
  (1, 'has_personalized_recommendations', 0), (2, 'has_personalized_recommendations', 0), (3, 'has_personalized_recommendations', 1), (4, 'has_personalized_recommendations', 1),
  (1, 'has_priority_content_updates', 0), (2, 'has_priority_content_updates', 0), (3, 'has_priority_content_updates', 1), (4, 'has_priority_content_updates', 1),
  (1, 'has_priority_support', 0), (2, 'has_priority_support', 0), (3, 'has_priority_support', 0), (4, 'has_priority_support', 1),
  (1, 'has_early_access', 0), (2, 'has_early_access', 0), (3, 'has_early_access', 0), (4, 'has_early_access', 1),
  (1, 'has_premium_ai_suite', 0), (2, 'has_premium_ai_suite', 0), (3, 'has_premium_ai_suite', 0), (4, 'has_premium_ai_suite', 1)
ON CONFLICT (plan_id, feature_key) DO UPDATE SET feature_limit = EXCLUDED.feature_limit;

COMMIT;
'@
[System.IO.File]::WriteAllText("$PWD\migrations\0018_update_subscription_tiers.up.sql", $migrationContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Rewrote 0018_update_subscription_tiers.up.sql"

Write-Host ""
Write-Host "Verifying no corruption remains..."
Select-String -Path "migrations\0018_update_subscription_tiers.up.sql" -Pattern "ity_support"
Write-Host "(no output above = corrupted fragment is gone)"

Write-Host ""
Write-Host "Row count check - should be 11 INSERT lines with 4 values each in the flag block:"
Select-String -Path "migrations\0018_update_subscription_tiers.up.sql" -Pattern "^\s*\(1, 'has_"
