# Run this from: C:\Users\ABC\Desktop\AI_Mentor\frontend
# Usage:  .\fix_quick_actions.ps1

$ErrorActionPreference = "Stop"

$quickActionsContent = @'
import "package:flutter/material.dart";

import "../../../core/widgets/premium_bottom_sheet.dart";

class _QuickAction {
  final IconData icon;
  final String label;
  final String? featureKey;

  const _QuickAction({required this.icon, required this.label, this.featureKey});
}

class QuickActionsSection extends StatelessWidget {
  final Map<String, int> features;

  const QuickActionsSection({super.key, required this.features});

  static const _actions = [
    _QuickAction(icon: Icons.chat_bubble_outline, label: "Ask Doubt"),
    _QuickAction(icon: Icons.description_outlined, label: "Notes"),
    _QuickAction(icon: Icons.fact_check_outlined, label: "Tests"),
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

            return GestureDetector(
              onTap: isLocked ? () => showPremiumBottomSheet(context) : null,
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

Write-Host ""
Write-Host "Verifying..."
Select-String -Path "lib\presentation\home\widgets\quick_actions_section.dart" -Pattern "required this.features"

Write-Host ""
Write-Host "Now run: flutter analyze"
