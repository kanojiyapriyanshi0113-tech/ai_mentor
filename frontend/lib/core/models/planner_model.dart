/// Data model for a single AI Planner entry.
///
/// Mirrors what a future planner API resource would look like, so the
/// UI and provider layers won't need to change once a real backend
/// endpoint exists - only MockPlannerService would be swapped out.
class PlannerPlan {
  final String id;
  final DateTime date;
  final String goal;
  final bool isCompleted;
  final DateTime createdAt;

  const PlannerPlan({
    required this.id,
    required this.date,
    required this.goal,
    this.isCompleted = false,
    required this.createdAt,
  });

  PlannerPlan copyWith({
    String? id,
    DateTime? date,
    String? goal,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return PlannerPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      goal: goal ?? this.goal,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
