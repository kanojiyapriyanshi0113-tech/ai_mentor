import "package:flutter/material.dart";

import "../models/practice_dummy_models.dart";

class DppCard extends StatelessWidget {
  final DailyPracticeDummy dpp;
  final VoidCallback onTap;

  const DppCard({super.key, required this.dpp, required this.onTap});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return "Today";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: dpp.completed ? Colors.green : Colors.grey[300],
              child: Icon(
                dpp.completed ? Icons.check : Icons.edit_note_outlined,
                color: dpp.completed ? Colors.white : Colors.grey[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dpp.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    "${dpp.subjectTag} · ${dpp.totalQuestions} Qs · ${_formatDate(dpp.date)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
