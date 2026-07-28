import "package:flutter/material.dart";

class MockTestDummy {
  final String id;
  final String title;
  final String subjectTag;
  final int totalQuestions;
  final int durationMinutes;
  final bool attempted;
  final int? scorePercent;

  const MockTestDummy({
    required this.id,
    required this.title,
    required this.subjectTag,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.attempted,
    this.scorePercent,
  });
}

class DailyPracticeDummy {
  final String id;
  final String title;
  final String subjectTag;
  final int totalQuestions;
  final DateTime date;
  final bool completed;

  const DailyPracticeDummy({
    required this.id,
    required this.title,
    required this.subjectTag,
    required this.totalQuestions,
    required this.date,
    required this.completed,
  });
}

class PreviousYearQuestionDummy {
  final String id;
  final String examName;
  final int year;
  final String subjectTag;
  final int totalQuestions;

  const PreviousYearQuestionDummy({
    required this.id,
    required this.examName,
    required this.year,
    required this.subjectTag,
    required this.totalQuestions,
  });
}

class BookmarkedQuestionDummy {
  final String id;
  final String questionText;
  final String subjectTag;
  final String sourceTag;

  const BookmarkedQuestionDummy({
    required this.id,
    required this.questionText,
    required this.subjectTag,
    required this.sourceTag,
  });
}

class DummyPracticeRepository {
  static List<MockTestDummy> getMockTests() {
    return const [
      MockTestDummy(
        id: "mt1",
        title: "Full Syllabus Mock Test 3",
        subjectTag: "JEE",
        totalQuestions: 90,
        durationMinutes: 180,
        attempted: true,
        scorePercent: 74,
      ),
      MockTestDummy(
        id: "mt2",
        title: "Physics Sectional Test",
        subjectTag: "Physics",
        totalQuestions: 30,
        durationMinutes: 60,
        attempted: true,
        scorePercent: 61,
      ),
      MockTestDummy(
        id: "mt3",
        title: "Full Syllabus Mock Test 4",
        subjectTag: "JEE",
        totalQuestions: 90,
        durationMinutes: 180,
        attempted: false,
        scorePercent: null,
      ),
      MockTestDummy(
        id: "mt4",
        title: "Chemistry Sectional Test",
        subjectTag: "Chemistry",
        totalQuestions: 30,
        durationMinutes: 60,
        attempted: false,
        scorePercent: null,
      ),
    ];
  }

  static List<DailyPracticeDummy> getDailyPractice() {
    final today = DateTime.now();
    return [
      DailyPracticeDummy(
        id: "dpp1",
        title: "DPP — Laws of Motion",
        subjectTag: "Physics",
        totalQuestions: 15,
        date: today,
        completed: false,
      ),
      DailyPracticeDummy(
        id: "dpp2",
        title: "DPP — Chemical Bonding",
        subjectTag: "Chemistry",
        totalQuestions: 12,
        date: today.subtract(const Duration(days: 1)),
        completed: true,
      ),
      DailyPracticeDummy(
        id: "dpp3",
        title: "DPP — Calculus Basics",
        subjectTag: "Maths",
        totalQuestions: 10,
        date: today.subtract(const Duration(days: 2)),
        completed: true,
      ),
    ];
  }

  static List<PreviousYearQuestionDummy> getPreviousYearQuestions() {
    return const [
      PreviousYearQuestionDummy(
        id: "pyq1",
        examName: "JEE Main",
        year: 2025,
        subjectTag: "Physics",
        totalQuestions: 25,
      ),
      PreviousYearQuestionDummy(
        id: "pyq2",
        examName: "JEE Main",
        year: 2024,
        subjectTag: "Chemistry",
        totalQuestions: 25,
      ),
      PreviousYearQuestionDummy(
        id: "pyq3",
        examName: "NEET",
        year: 2025,
        subjectTag: "Biology",
        totalQuestions: 45,
      ),
      PreviousYearQuestionDummy(
        id: "pyq4",
        examName: "NEET",
        year: 2024,
        subjectTag: "Physics",
        totalQuestions: 45,
      ),
    ];
  }

  static List<BookmarkedQuestionDummy> getBookmarkedQuestions() {
    return const [
      BookmarkedQuestionDummy(
        id: "bq1",
        questionText: "A block of mass 5kg is placed on a frictionless incline of 30°. Find the acceleration.",
        subjectTag: "Physics",
        sourceTag: "Mock Test 3",
      ),
      BookmarkedQuestionDummy(
        id: "bq2",
        questionText: "Which of the following has the highest lattice energy?",
        subjectTag: "Chemistry",
        sourceTag: "DPP — Chemical Bonding",
      ),
      BookmarkedQuestionDummy(
        id: "bq3",
        questionText: "Evaluate the integral of x²sin(x) dx.",
        subjectTag: "Maths",
        sourceTag: "JEE Main 2024",
      ),
    ];
  }
}
