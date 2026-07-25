import "package:flutter/material.dart";

import "../../../core/network/course_api_service.dart";

// Stopgap client-side lookup — backend /course/batches returns only exam_id,
// not the exam name/code. Update this if new exams are seeded, or better,
// have the backend include exam_code in BatchResponse.
const Map<int, String> _examCodeById = {
  1: "UPSC",
  2: "SSC",
  3: "BANKING",
  4: "RAILWAY",
  5: "NEET",
  6: "JEE",
  7: "STATE PSC",
};

const List<Color> _colorPalette = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.purple,
  Colors.blueGrey,
  Colors.green,
];

// Deterministic color per id, since Batch/Subject entities carry no color field.
Color colorForBatch(String id) => _colorPalette[id.hashCode.abs() % _colorPalette.length];

String examCodeForBatch(int examId) => _examCodeById[examId] ?? "Exam";

class CourseCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.batch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForBatch(batch.id);
    final examTag = examCodeForBatch(batch.examId);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: batch.thumbnail.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        batch.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.menu_book_outlined, color: color, size: 28),
                      ),
                    )
                  : Icon(Icons.menu_book_outlined, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      examTag,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    batch.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  if (batch.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      batch.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}