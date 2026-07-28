import "package:flutter/material.dart";

class _UpdateItem {
  final String title;
  final String time;
  final IconData icon;

  const _UpdateItem({required this.title, required this.time, required this.icon});
}

class LatestUpdatesSection extends StatelessWidget {
  const LatestUpdatesSection({super.key});

  static const _updates = [
    _UpdateItem(title: "New DPP added for Physics Chapter 4", time: "2h ago", icon: Icons.assignment_outlined),
    _UpdateItem(title: "Live doubt session scheduled tomorrow", time: "5h ago", icon: Icons.campaign_outlined),
    _UpdateItem(title: "Mock Test 3 results are out", time: "1d ago", icon: Icons.emoji_events_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Latest Updates", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...(_updates.map((update) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(update.icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(update.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  Text(update.time, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }
}
