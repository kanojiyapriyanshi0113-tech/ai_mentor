import "package:dio/dio.dart";

import "../models/subscription_model.dart";
import "api_client.dart";

class SubscriptionApiService {
  final Dio _dio = ApiClient().dio;

  Future<SubscriptionSummary> getSubscriptionSummary() async {
    final response = await _dio.get("/subscription");
    final data = response.data["data"] as Map<String, dynamic>;
    return SubscriptionSummary.fromApiJson(data);
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _dio.get("/plans");
    final data = response.data["data"] as List<dynamic>;
    return data
        .map((e) => SubscriptionPlan.fromApiJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getFeatures() async {
    final response = await _dio.get("/subscription/features");
    final data = response.data["data"] as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> upgradePlan(String planCode) async {
    await _dio.post("/subscription/upgrade", data: {"plan_code": planCode});
  }
}