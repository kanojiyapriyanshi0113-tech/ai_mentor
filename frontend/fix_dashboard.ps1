# Run this from: C:\Users\ABC\Desktop\AI_Mentor\frontend
# Usage:  .\fix_dashboard.ps1

$ErrorActionPreference = "Stop"

# 1. API service - add missing getFeatures()
$apiServiceContent = @'
import "package:dio/dio.dart";

import "../models/subscription_model.dart";
import "api_client.dart";

class SubscriptionApiService {
  final Dio _dio = ApiClient().dio;

  Future<SubscriptionSummary> getSubscriptionSummary() async {
    final response = await _dio.get("/subscription");
    final data = response.data["data"] as Map<String, dynamic>;
    return SubscriptionSummary.fromApiJson(data);
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _dio.get("/plans");
    final data = response.data["data"] as List<dynamic>;
    return data
        .map((e) => SubscriptionPlan.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getFeatures() async {
    final response = await _dio.get("/subscription/features");
    final data = response.data["data"] as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> upgradePlan(String planCode) async {
    await _dio.post("/subscription/upgrade", data: {"plan_code": planCode});
  }
}
'@
[System.IO.File]::WriteAllText("$PWD\lib\core\network\subscription_api_service.dart", $apiServiceContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Wrote subscription_api_service.dart"

# 2. New file - gated features section
$featureAccessContent = @'
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../core/providers/subscription_provider.dart";
import "../../../core/widgets/premium_bottom_sheet.dart";

class _GatedFeature {
  final IconData icon;
  final String label;
  final String featureKey;

  const _GatedFeature({required this.icon, required this.label, required this.featureKey});
}

class FeatureAccessSection extends StatelessWidget {
  const FeatureAccessSection({super.key});

  static const _features = [
    _GatedFeature(icon: Icons.calendar_month_outlined, label: "AI Planner", featureKey: "has_ai_planner"),
    _GatedFeature(icon: Icons.note_alt_outlined, label: "AI Notes", featureKey: "has_ai_notes"),
    _GatedFeature(icon: Icons.image_outlined, label: "Image Doubt Upload", featureKey: "has_image_doubt_upload"),
    _GatedFeature(icon: Icons.upload_file_outlined, label: "Document Upload", featureKey: "has_document_upload"),
    _GatedFeature(icon: Icons.insights_outlined, label: "Performance Analytics", featureKey: "has_performance_analytics"),
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

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isUnlocked ? null : () => showPremiumBottomSheet(context),
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
Write-Host "feature_access_section.dart exists: $(Test-Path 'lib\presentation\home\widgets\feature_access_section.dart')"
Select-String -Path "lib\core\network\subscription_api_service.dart" -Pattern "getFeatures"

Write-Host ""
Write-Host "Now run: flutter analyze"
