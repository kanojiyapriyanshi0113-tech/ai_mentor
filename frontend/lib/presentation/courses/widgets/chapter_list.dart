import "package:flutter/material.dart";

import "../../../core/network/course_api_service.dart";

class ChapterList extends StatelessWidget {
  final List<Chapter> chapters;
  final Color accentColor;
  final ValueChanged<Chapter> onTapChapter;

  const ChapterList({
    super.key,
    required this.chapters,
    required this.accentColor,
    required this.onTapChapter,
  });

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text("No chapters available", style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final chapter = chapters[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTapChapter(chapter),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accentColor,
                  child: const Icon(Icons.menu_book_outlined, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      if (chapter.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          chapter.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[500]),
              ],
            ),
          ),
        );
      },
    );
  }
}