import "package:flutter/material.dart";

import "../models/subscription_model.dart";
import "../network/subscription_api_service.dart";

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionApiService _service = SubscriptionApiService();

  SubscriptionSummary? _summary;
  List<SubscriptionPlan> _plans = [];
  Map<String, int> _features = {};
  bool _isLoadingSummary = false;
  bool _isLoadingPlans = false;
  bool _isLoadingFeatures = false;
  String? _summaryError;
  String? _plansError;
  String? _featuresError;

  SubscriptionSummary? get summary => _summary;
  List<SubscriptionPlan> get plans => _plans;
  Map<String, int> get features => _features;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingPlans => _isLoadingPlans;
  bool get isLoadingFeatures => _isLoadingFeatures;
  String? get summaryError => _summaryError;
  String? get plansError => _plansError;
  String? get featuresError => _featuresError;

  Future<void> loadSummary() async {
    _isLoadingSummary = true;
    _summaryError = null;
    notifyListeners();

    try {
      _summary = await _service.getSubscriptionSummary();
    } catch (e) {
      _summaryError = "Failed to load subscription details.";
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  Future<void> loadPlans() async {
    _isLoadingPlans = true;
    _plansError = null;
    notifyListeners();

    try {
      _plans = await _service.getPlans();
    } catch (e) {
      _plansError = "Failed to load plans.";
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  Future<void> loadFeatures() async {
    _isLoadingFeatures = true;
    _featuresError = null;
    notifyListeners();

    try {
      _features = await _service.getFeatures();
    } catch (e) {
      _featuresError = "Failed to load features.";
    } finally {
      _isLoadingFeatures = false;
      notifyListeners();
    }
  }

  Future<bool> upgradePlan(String planCode) async {
    try {
      await _service.upgradePlan(planCode);
      await loadSummary();
      await loadFeatures();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clear() {
    _summary = null;
    _plans = [];
    _features = {};
    notifyListeners();
  }
}