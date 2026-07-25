import "package:flutter/material.dart";

import "../../../core/models/subscription_model.dart";

class SubscriptionCard extends StatelessWidget {
  final SubscriptionSummary? summary;
  final bool isLoading;
  final VoidCallback onUpgradeTap;

  const SubscriptionCard({
    super.key,
    required this.summary,
    required this.isLoading,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = summary != null && !summary!.isFreeTrial;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [Colors.amber[700]!, Colors.amber[400]!]
                    : [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isPremium ? Icons.workspace_premium : Icons.hourglass_bottom,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading ? "Loading..." : (summary?.currentPlan ?? "Free Trial"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLoading
                            ? " "
                            : isPremium
                                ? "You have full access to all features"
                                : "${summary?.trialDaysLeft ?? 0} days left in your trial",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!isPremium)
                  GestureDetector(
                    onTap: onUpgradeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Upgrade",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                    children: [
                      _StatTile(
                        icon: Icons.chat_bubble_outline,
                        label: "AI Questions Today",
                        value: summary?.aiQuestionsRemaining ?? 0,
                      ),
                      _StatTile(
                        icon: Icons.quiz_outlined,
                        label: "Mock Tests",
                        value: summary?.mockTestsRemaining ?? 0,
                      ),
                      _StatTile(
                        icon: Icons.menu_book_outlined,
                        label: "Chapters",
                        value: summary?.chaptersRemaining ?? 0,
                      ),
                      _StatTile(
                        icon: Icons.play_circle_outline,
                        label: "Videos",
                        value: summary?.videosRemaining ?? 0,
                      ),
                      _StatTile(
                        icon: Icons.picture_as_pdf_outlined,
                        label: "PDF Notes",
                        value: summary?.pdfNotesRemaining ?? 0,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$value",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}