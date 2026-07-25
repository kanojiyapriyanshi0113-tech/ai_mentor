# Run this from: C:\Users\ABC\Desktop\AI_Mentor\frontend
# Usage:  .\fix_quick_actions_nav.ps1

$ErrorActionPreference = "Stop"

$quickActionsContent = @'
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../core/router/app_routes.dart";
import "../../../core/widgets/premium_bottom_sheet.dart";

class _QuickAction {
  final IconData icon;
  final String label;
  final String? featureKey;
  final String? route;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.featureKey,
    this.route,
  });
}

class QuickActionsSection extends StatelessWidget {
  final Map<String, int> features;

  const QuickActionsSection({super.key, required this.features});

  static const _actions = [
    _QuickAction(icon: Icons.chat_bubble_outline, label: "Ask Doubt", route: AppRoutes.aiMentor),
    _QuickAction(icon: Icons.description_outlined, label: "Notes", route: AppRoutes.courses),
    _QuickAction(icon: Icons.fact_check_outlined, label: "Tests", route: AppRoutes.practice),
    _QuickAction(icon: Icons.live_tv_outlined, label: "Live Class", featureKey: "has_live_classes"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _actions.map((action) {
            final isLocked = action.featureKey != null &&
                (features[action.featureKey] ?? 0) == 0;

            VoidCallback? onTap;
            if (isLocked) {
              onTap = () => showPremiumBottomSheet(context);
            } else if (action.route != null) {
              onTap = () => context.push(action.route!);
            }

            return GestureDetector(
              onTap: onTap,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey[200]
                              : Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          action.icon,
                          color: isLocked ? Colors.grey[500] : Theme.of(context).primaryColor,
                        ),
                      ),
                      if (isLocked)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.lock, size: 12, color: Colors.grey[600]),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isLocked ? Colors.grey[500] : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
'@
[System.IO.File]::WriteAllText("$PWD\lib\presentation\home\widgets\quick_actions_section.dart", $quickActionsContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Wrote quick_actions_section.dart"

$featureAccessContent = @'
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

import "../../../core/providers/subscription_provider.dart";
import "../../../core/router/app_routes.dart";
import "../../../core/widgets/premium_bottom_sheet.dart";

class _GatedFeature {
  final IconData icon;
  final String label;
  final String featureKey;
  final String? route;

  const _GatedFeature({
    required this.icon,
    required this.label,
    required this.featureKey,
    this.route,
  });
}

class FeatureAccessSection extends StatelessWidget {
  const FeatureAccessSection({super.key});

  static const _features = [
    _GatedFeature(icon: Icons.calendar_month_outlined, label: "AI Planner", featureKey: "has_ai_planner"),
    _GatedFeature(icon: Icons.note_alt_outlined, label: "AI Notes", featureKey: "has_ai_notes"),
    _GatedFeature(icon: Icons.image_outlined, label: "Image Doubt Upload", featureKey: "has_image_doubt_upload", route: AppRoutes.aiMentor),
    _GatedFeature(icon: Icons.upload_file_outlined, label: "Document Upload", featureKey: "has_document_upload", route: AppRoutes.aiMentor),
    _GatedFeature(icon: Icons.insights_outlined, label: "Performance Analytics", featureKey: "has_performance_analytics", route: AppRoutes.aiMentor),
    _GatedFeature(icon: Icons.recommend_outlined, label: "Personalized Recommendations", featureKey: "has_personalized_recommendations"),
  ];

  @override
  Widget build(BuildContext context) {
    final features = context.watch<SubscriptionProvider>().features;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("More Features", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ..._features.map((f) {
          final isUnlocked = (features[f.featureKey] ?? 0) != 0;

          VoidCallback? onTap;
          if (!isUnlocked) {
            onTap = () => showPremiumBottomSheet(context);
          } else if (f.route != null) {
            onTap = () => context.push(f.route!);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      f.icon,
                      size: 20,
                      color: isUnlocked ? Theme.of(context).primaryColor : Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isUnlocked ? Colors.black87 : Colors.grey[500],
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      Icon(Icons.lock_outline, size: 18, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
'@
[System.IO.File]::WriteAllText("$PWD\lib\presentation\home\widgets\feature_access_section.dart", $featureAccessContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Wrote feature_access_section.dart"

Write-Host ""
Write-Host "Verifying..."
Select-String -Path "lib\presentation\home\widgets\quick_actions_section.dart" -Pattern "context.push"
Select-String -Path "lib\presentation\home\widgets\feature_access_section.dart" -Pattern "context.push"

Write-Host ""
Write-Host "Now run: flutter analyze"
