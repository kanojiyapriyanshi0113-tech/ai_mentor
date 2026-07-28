import "package:dio/dio.dart";

import "../models/planner_model.dart";
import "../providers/planner_provider.dart";
import "api_client.dart";

/// Converts a [DateTime] to an RFC3339 string that always carries a
/// timezone offset (e.g. "2026-07-28T00:00:00.000+05:30").
///
/// Go's time.Time JSON unmarshal requires an explicit offset. A bare
/// DateTime.toIso8601String() on a *local* DateTime omits the offset
/// entirely (e.g. "2026-07-28T00:00:00.000"), which the backend rejects
/// as invalid input. This always converts to UTC first, so the emitted
/// string reliably ends in "Z" (a valid RFC3339 offset) regardless of
/// the device's local timezone.
String _toRfc3339(DateTime date) => date.toUtc().toIso8601String();

extension _PlannerPlanJson on PlannerPlan {
  Map<String, dynamic> toJson() => {
        "date": _toRfc3339(date),
        "goal": goal,
        "is_completed": isCompleted,
      };
}

PlannerPlan _planFromJson(Map<String, dynamic> json) {
  return PlannerPlan(
    id: json["id"] as String,
    date: DateTime.parse(json["date"] as String),
    goal: json["goal"] as String,
    isCompleted: json["is_completed"] as bool,
    createdAt: DateTime.parse(json["created_at"] as String),
  );
}

/// API-backed implementation of [PlannerService], calling the
/// /api/planner/plans endpoints.
class PlannerApiService implements PlannerService {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<PlannerPlan>> fetchPlans() async {
    final response = await _dio.get("/planner/plans");
    final list = response.data["data"] as List<dynamic>;
    return list.map((e) => _planFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<PlannerPlan> createPlan(PlannerPlan plan) async {
    final response = await _dio.post("/planner/plans", data: plan.toJson());
    return _planFromJson(response.data["data"] as Map<String, dynamic>);
  }

  @override
  Future<PlannerPlan> updatePlan(PlannerPlan plan) async {
    final response = await _dio.put("/planner/plans/${plan.id}", data: plan.toJson());
    return _planFromJson(response.data["data"] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePlan(String id) async {
    await _dio.delete("/planner/plans/$id");
  }

  @override
  Future<PlannerPlan> completePlan(String id) async {
    final response = await _dio.post("/planner/plans/$id/complete");
    return _planFromJson(response.data["data"] as Map<String, dynamic>);
  }
}