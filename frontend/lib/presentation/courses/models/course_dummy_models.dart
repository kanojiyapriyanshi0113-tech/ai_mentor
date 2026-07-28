import "package:flutter/material.dart";

class ChapterDummy {
  final String id;
  final String title;
  final int lecturesCount;
  final bool completed;

  const ChapterDummy({
    required this.id,
    required this.title,
    required this.lecturesCount,
    required this.completed,
  });
}

class SubjectDummy {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<ChapterDummy> chapters;

  const SubjectDummy({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.chapters,
  });
}

class CourseDummy {
  final String id;
  final String title;
  final String examTag;
  final IconData icon;
  final Color color;
  final double progress;
  final List<SubjectDummy> subjects;

  const CourseDummy({
    required this.id,
    required this.title,
    required this.examTag,
    required this.icon,
    required this.color,
    required this.progress,
    required this.subjects,
  });
}

class DummyCoursesRepository {
  static List<CourseDummy> getCourses() {
    return [
      CourseDummy(
        id: "c1",
        title: "JEE Complete Batch",
        examTag: "JEE",
        icon: Icons.engineering,
        color: Colors.indigo,
        progress: 0.58,
        subjects: [
          SubjectDummy(
            id: "s1",
            name: "Physics",
            icon: Icons.bolt_outlined,
            color: Colors.indigo,
            chapters: const [
              ChapterDummy(id: "ch1", title: "Laws of Motion", lecturesCount: 8, completed: true),
              ChapterDummy(id: "ch2", title: "Work, Energy and Power", lecturesCount: 6, completed: true),
              ChapterDummy(id: "ch3", title: "Rotational Motion", lecturesCount: 10, completed: false),
              ChapterDummy(id: "ch4", title: "Gravitation", lecturesCount: 5, completed: false),
            ],
          ),
          SubjectDummy(
            id: "s2",
            name: "Chemistry",
            icon: Icons.science_outlined,
            color: Colors.teal,
            chapters: const [
              ChapterDummy(id: "ch5", title: "Chemical Bonding", lecturesCount: 7, completed: true),
              ChapterDummy(id: "ch6", title: "Organic Basics", lecturesCount: 9, completed: false),
            ],
          ),
          SubjectDummy(
            id: "s3",
            name: "Maths",
            icon: Icons.calculate_outlined,
            color: Colors.purple,
            chapters: const [
              ChapterDummy(id: "ch7", title: "Calculus", lecturesCount: 12, completed: false),
              ChapterDummy(id: "ch8", title: "Coordinate Geometry", lecturesCount: 8, completed: false),
            ],
          ),
        ],
      ),
      CourseDummy(
        id: "c2",
        title: "NEET Target Batch",
        examTag: "NEET",
        icon: Icons.local_hospital_outlined,
        color: Colors.red,
        progress: 0.32,
        subjects: [
          SubjectDummy(
            id: "s4",
            name: "Biology",
            icon: Icons.eco_outlined,
            color: Colors.green,
            chapters: const [
              ChapterDummy(id: "ch9", title: "Cell Structure", lecturesCount: 6, completed: true),
              ChapterDummy(id: "ch10", title: "Human Physiology", lecturesCount: 14, completed: false),
            ],
          ),
          SubjectDummy(
            id: "s5",
            name: "Chemistry",
            icon: Icons.science_outlined,
            color: Colors.teal,
            chapters: const [
              ChapterDummy(id: "ch11", title: "Periodic Table", lecturesCount: 5, completed: false),
            ],
          ),
        ],
      ),
      CourseDummy(
        id: "c3",
        title: "UPSC Foundation",
        examTag: "UPSC",
        icon: Icons.account_balance_outlined,
        color: Colors.brown,
        progress: 0.12,
        subjects: [
          SubjectDummy(
            id: "s6",
            name: "Polity",
            icon: Icons.gavel_outlined,
            color: Colors.brown,
            chapters: const [
              ChapterDummy(id: "ch12", title: "Constitution Basics", lecturesCount: 4, completed: false),
            ],
          ),
        ],
      ),
    ];
  }
}
