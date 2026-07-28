/// Simple data model representing a single saved plan entry.
///
/// This is UI-only: there is no backend or API behind it yet. Values are
/// kept in memory purely so PlanHistoryScreen has something to display.
class PlanEntry {
  final DateTime date;
  final String goal;

  const PlanEntry({
    required this.date,
    required this.goal,
  });
}

/// Static, in-memory sample data for the plan history list.
///
/// Replace with a real repository once a backend endpoint exists.
class DummyPlannerRepository {
  DummyPlannerRepository._();

  static List<PlanEntry> getHistory() {
    final now = DateTime.now();
    return [
      PlanEntry(
        date: DateTime(now.year, now.month, now.day - 1),
        goal: "Revise Physics - Laws of Motion chapter",
      ),
      PlanEntry(
        date: DateTime(now.year, now.month, now.day - 3),
        goal: "Complete 2 mock tests and review mistakes",
      ),
      PlanEntry(
        date: DateTime(now.year, now.month, now.day - 7),
        goal: "Finish Organic Chemistry notes and flashcards",
      ),
    ];
  }
}
