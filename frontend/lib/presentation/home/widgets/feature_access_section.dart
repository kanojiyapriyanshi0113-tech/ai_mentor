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
    _GatedFeature(icon: Icons.calendar_month_outlined, label: "AI Planner", featureKey: "has_ai_planner", route: AppRoutes.aiPlanner),
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