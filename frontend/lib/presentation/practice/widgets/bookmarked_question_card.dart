import "package:flutter/material.dart";

import "../models/practice_dummy_models.dart";

class BookmarkedQuestionCard extends StatelessWidget {
  final BookmarkedQuestionDummy question;
  final VoidCallback onTap;
  final VoidCallback onRemoveBookmark;

  const BookmarkedQuestionCard({
    super.key,
    required this.question,
    required this.onTap,
    required this.onRemoveBookmark,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark, color: Colors.amber, size: 20),
                  onPressed: onRemoveBookmark,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.subjectTag,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "From: ${question.sourceTag}",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
