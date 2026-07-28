import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:go_router/go_router.dart";

import "../../../core/providers/course_provider.dart";

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();

    if (courseProvider.isLoadingProgress) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final progress = courseProvider.batchProgress;
    final continueLearning = progress?.continueLearning;

    if (progress == null || continueLearning == null) {
      // No batch enrolled yet, or every lecture already completed.
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                progress == null
                    ? "Enroll in a batch to start learning"
                    : "You're all caught up! No pending lectures.",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final progressValue = progress.totalLectures == 0
        ? 0.0
        : progress.completedLectures / progress.totalLectures;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push("/lecture/${continueLearning.lectureId}"),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Continue Learning",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    continueLearning.lectureTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    continueLearning.chapterTitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    ),
                  ),
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
