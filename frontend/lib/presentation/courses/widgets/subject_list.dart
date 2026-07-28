import "package:flutter/material.dart";

import "../../../core/network/course_api_service.dart";
import "course_card.dart" show colorForBatch;

class SubjectList extends StatelessWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final ValueChanged<Subject> onSelect;

  const SubjectList({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = subject.id == selectedSubject?.id;
          final color = colorForBatch(subject.id);

          return GestureDetector(
            onTap: () => onSelect(subject),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 84,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  subject.icon.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            subject.icon,
                            width: 26,
                            height: 26,
                            errorBuilder: (_, __, ___) => Icon(Icons.book_outlined, color: color, size: 26),
                          ),
                        )
                      : Icon(Icons.book_outlined, color: color, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}