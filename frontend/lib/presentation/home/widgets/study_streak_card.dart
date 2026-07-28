import "package:flutter/material.dart";

class StudyStreakCard extends StatelessWidget {
  const StudyStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    const dummyStreakDays = 7;
    final dummyWeek = [true, true, true, true, true, false, false];
    const labels = ["M", "T", "W", "T", "F", "S", "S"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 26),
              const SizedBox(width: 8),
              Text(
                "$dummyStreakDays Day Streak",
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = dummyWeek[i];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: active ? Colors.deepOrange : Colors.grey[300],
                    child: Icon(
                      active ? Icons.local_fire_department : Icons.circle_outlined,
                      size: 14,
                      color: active ? Colors.white : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
