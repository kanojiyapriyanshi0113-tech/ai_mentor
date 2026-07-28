import "package:flutter/material.dart";

import "../models/practice_dummy_models.dart";

class PyqCard extends StatelessWidget {
  final PreviousYearQuestionDummy pyq;
  final VoidCallback onTap;

  const PyqCard({super.key, required this.pyq, required this.onTap});

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
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${pyq.year}",
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${pyq.examName} ${pyq.year}",
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${pyq.subjectTag} · ${pyq.totalQuestions} Qs",
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
