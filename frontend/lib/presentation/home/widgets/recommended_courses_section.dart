import "package:flutter/material.dart";

class _CourseItem {
  final String title;
  final String tag;
  final IconData icon;
  final Color color;

  const _CourseItem({
    required this.title,
    required this.tag,
    required this.icon,
    required this.color,
  });
}

class RecommendedCoursesSection extends StatelessWidget {
  const RecommendedCoursesSection({super.key});

  static const _courses = [
    _CourseItem(title: "Mechanics Mastery", tag: "Physics", icon: Icons.rocket_launch_outlined, color: Colors.indigo),
    _CourseItem(title: "Organic Chemistry", tag: "Chemistry", icon: Icons.science_outlined, color: Colors.teal),
    _CourseItem(title: "Calculus Foundations", tag: "Maths", icon: Icons.calculate_outlined, color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recommended Courses", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final course = _courses[index];
              return Container(
                width: 160,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: course.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: course.color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(course.icon, color: course.color, size: 28),
                    const Spacer(),
                    Text(
                      course.tag,
                      style: TextStyle(fontSize: 11, color: course.color, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
