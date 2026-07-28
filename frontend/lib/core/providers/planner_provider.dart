import "package:dio/dio.dart";
import "package:flutter/material.dart";

import "../models/planner_model.dart";
import "../network/planner_api_service.dart";

/// Data-access contract for the AI Planner feature.
///
/// No backend endpoint exists yet. This interface is what a future
/// API-backed implementation would satisfy, so PlannerProvider itself
/// won't need to change when that lands - only the service passed into
/// it would.
abstract class PlannerService {
  Future<List<PlannerPlan>> fetchPlans();
  Future<PlannerPlan> createPlan(PlannerPlan plan);
  Future<PlannerPlan> updatePlan(PlannerPlan plan);
  Future<void> deletePlan(String id);
  Future<PlannerPlan> completePlan(String id);
}

/// In-memory mock implementation of [PlannerService].
///
/// Seeded with sample data and simulates network latency with a short
/// delay so PlannerProvider's loading states behave the same way they
/// will once a real API is wired in. All mutations are local-only.
class MockPlannerService implements PlannerService {
  final List<PlannerPlan> _store = [
    PlannerPlan(
      id: "p1",
      date: DateTime.now().subtract(const Duration(days: 1)),
      goal: "Revise Physics - Laws of Motion chapter",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PlannerPlan(
      id: "p2",
      date: DateTime.now().subtract(const Duration(days: 3)),
      goal: "Complete 2 mock tests and review mistakes",
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  int _nextId = 3;

  @override
  Future<List<PlannerPlan>> fetchPlans() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_store);
  }

  @override
  Future<PlannerPlan> createPlan(PlannerPlan plan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final created = plan.copyWith(id: "p${_nextId++}");
    _store.add(created);
    return created;
  }

  @override
  Future<PlannerPlan> updatePlan(PlannerPlan plan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.indexWhere((p) => p.id == plan.id);
    if (index == -1) {
      throw StateError("Plan with id ${plan.id} not found");
    }
    _store[index] = plan;
    return plan;
  }

  @override
  Future<void> deletePlan(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.removeWhere((p) => p.id == id);
  }

  @override
  Future<PlannerPlan> completePlan(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw StateError("Plan with id $id not found");
    }
    final updated = _store[index].copyWith(isCompleted: true);
    _store[index] = updated;
    return updated;
  }
}

/// Adapts [PlannerApiService] (the real backend client) to the
/// [PlannerService] contract expected by [PlannerProvider].
///
/// Every method maps 1:1 onto PlannerApiService except fetchPlans, which
/// is named getPlans on the API service.
class ApiPlannerService implements PlannerService {
  final PlannerApiService _api;

  ApiPlannerService({PlannerApiService? api}) : _api = api ?? PlannerApiService();

  @override
  Future<List<PlannerPlan>> fetchPlans() => _api.fetchPlans();
  @override
  Future<PlannerPlan> createPlan(PlannerPlan plan) => _api.createPlan(plan);

  @override
  Future<PlannerPlan> updatePlan(PlannerPlan plan) => _api.updatePlan(plan);

  @override
  Future<void> deletePlan(String id) => _api.deletePlan(id);

  @override
  Future<PlannerPlan> completePlan(String id) => _api.completePlan(id);
}

/// Provider for the AI Planner feature.
///
/// Backed by the real [ApiPlannerService] (which talks to the backend via
/// [PlannerApiService]) by default. [MockPlannerService] is kept available
/// for tests or offline use - pass it in explicitly via the constructor.
class PlannerProvider extends ChangeNotifier {
  final PlannerService _service;

  PlannerProvider({PlannerService? service}) : _service = service ?? ApiPlannerService();

  List<PlannerPlan> _plans = [];
  bool _isLoading = false;
  String? _error;

  List<PlannerPlan> get plans => List.unmodifiable(_plans);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Turns a caught error into a message that actually helps diagnose
  /// what went wrong, instead of a generic "failed" string.
  String _describeError(Object e, String fallback) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
          return "Can't reach the server. Check the backend is running and reachable.";
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return "Server took too long to respond. Please try again.";
        default:
          final status = e.response?.statusCode;
          if (status == 404) return "Planner endpoint not found on the server (404).";
          if (status == 401 || status == 403) return "You're not authorized. Please log in again.";
          if (status != null) return "$fallback (server returned $status).";
          return fallback;
      }
    }
    return fallback;
  }

  List<PlannerPlan> plansForDate(DateTime date) {
    return _plans
        .where((p) => p.date.year == date.year && p.date.month == date.month && p.date.day == date.day)
        .toList();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _plans = await _service.fetchPlans();
    } catch (e) {
      _error = _describeError(e, "Failed to load plans.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlan({required DateTime date, required String goal}) async {
    try {
      final plan = PlannerPlan(
        id: "",
        date: date,
        goal: goal,
        createdAt: DateTime.now(),
      );
      final created = await _service.createPlan(plan);
      _plans = [..._plans, created];
      notifyListeners();
      return true;
    } catch (e) {
      _error = _describeError(e, "Failed to save plan.");
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlan(String id, {DateTime? date, String? goal}) async {
    try {
      final index = _plans.indexWhere((p) => p.id == id);
      if (index == -1) return false;

      final updatedPlan = _plans[index].copyWith(date: date, goal: goal);
      final saved = await _service.updatePlan(updatedPlan);

      _plans = List.of(_plans)..[index] = saved;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _describeError(e, "Failed to update plan.");
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlan(String id) async {
    try {
      await _service.deletePlan(id);
      _plans = _plans.where((p) => p.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _describeError(e, "Failed to delete plan.");
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePlan(String id) async {
    try {
      final updated = await _service.completePlan(id);
      final index = _plans.indexWhere((p) => p.id == id);
      if (index == -1) return false;
      _plans = List.of(_plans)..[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _describeError(e, "Failed to update plan.");
      notifyListeners();
      return false;
    }
  }
}
