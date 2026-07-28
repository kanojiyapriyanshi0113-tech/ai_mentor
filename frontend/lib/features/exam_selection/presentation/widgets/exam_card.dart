import 'package:flutter/material.dart';
import '../../domain/exam.dart';

class ExamCard extends StatelessWidget {
  final ExamOption exam;
  final bool selected;
  final VoidCallback onTap;

  const ExamCard({
    super.key,
    required this.exam,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? primary : Colors.transparent, width: 2),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(exam.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              exam.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? primary : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
