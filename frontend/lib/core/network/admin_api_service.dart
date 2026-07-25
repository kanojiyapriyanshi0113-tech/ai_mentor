import "package:dio/dio.dart";

import "../models/admin_models.dart";
import "api_client.dart";

/// API service for the admin module (/api/admin/*).
/// Requires the caller to hold a JWT with role "admin" — enforced
/// server-side by RequireAdmin() middleware.
class AdminApiService {
  final Dio _dio = ApiClient().dio;

  Future<AdminDashboardModel> getDashboard() async {
    final response = await _dio.get("/admin/dashboard");
    final data = response.data["data"] as Map<String, dynamic>;
    return AdminDashboardModel.fromJson(data);
  }

  // ---- Teachers ----

  Future<TeacherAccountModel> addTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post("/admin/teachers", data: {
      "name": name,
      "email": email,
      "password": password,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return TeacherAccountModel.fromJson(data);
  }

  Future<void> approveTeacher(String id) async {
    await _dio.patch("/admin/teachers/$id/approve");
  }

  Future<void> editTeacher({
    required String id,
    required String name,
    required String email,
  }) async {
    await _dio.put("/admin/teachers/$id", data: {
      "name": name,
      "email": email,
    });
  }

  Future<void> suspendTeacher({required String id, required bool suspend}) async {
    await _dio.patch("/admin/teachers/$id/suspend", data: {"suspend": suspend});
  }

  Future<void> deleteTeacher(String id) async {
    await _dio.delete("/admin/teachers/$id");
  }

  Future<List<TeacherAccountModel>> listTeachers() async {
    final response = await _dio.get("/admin/teachers");
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => TeacherAccountModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- Students ----

  Future<List<StudentAccountModel>> listStudents({
    String search = "",
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get("/admin/students", queryParameters: {
      "search": search,
      "limit": limit,
      "offset": offset,
    });
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => StudentAccountModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> blockStudent({required String id, required bool block}) async {
    await _dio.patch("/admin/students/$id/block", data: {"block": block});
  }

  Future<void> deleteStudent(String id) async {
    await _dio.delete("/admin/students/$id");
  }

  // ---- Plans ----

  Future<AdminPlanModel> createPlan({
    required String code,
    required String name,
    required int durationDays,
    int pricePaise = 0,
    bool isTrial = false,
  }) async {
    final response = await _dio.post("/admin/subscriptions/plans", data: {
      "code": code,
      "name": name,
      "price_paise": pricePaise,
      "duration_days": durationDays,
      "is_trial": isTrial,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return AdminPlanModel.fromJson(data);
  }

  Future<void> updatePlan({
    required int id,
    required String name,
    required int durationDays,
    int pricePaise = 0,
    bool isTrial = false,
  }) async {
    await _dio.put("/admin/subscriptions/plans/$id", data: {
      "name": name,
      "price_paise": pricePaise,
      "duration_days": durationDays,
      "is_trial": isTrial,
    });
  }

  Future<void> enablePlan(int id) async {
    await _dio.patch("/admin/subscriptions/plans/$id/enable");
  }

  Future<void> disablePlan(int id) async {
    await _dio.patch("/admin/subscriptions/plans/$id/disable");
  }

  // ---- Coupons ----

  Future<CouponModel> createCoupon({
    required String code,
    required DateTime validUntil,
    int discountPercent = 0,
    int discountAmountPaise = 0,
    int maxUses = 0,
    DateTime? validFrom,
  }) async {
    final response = await _dio.post("/admin/coupons", data: {
      "code": code,
      "discount_percent": discountPercent,
      "discount_amount_paise": discountAmountPaise,
      "max_uses": maxUses,
      "valid_from": (validFrom ?? DateTime.now()).toUtc().toIso8601String(),
      "valid_until": validUntil.toUtc().toIso8601String(),
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return CouponModel.fromJson(data);
  }

  Future<void> updateCoupon({
    required String id,
    required DateTime validUntil,
    int discountPercent = 0,
    int discountAmountPaise = 0,
    int maxUses = 0,
    DateTime? validFrom,
    bool isActive = true,
  }) async {
    await _dio.put("/admin/coupons/$id", data: {
      "discount_percent": discountPercent,
      "discount_amount_paise": discountAmountPaise,
      "max_uses": maxUses,
      "valid_from": (validFrom ?? DateTime.now()).toUtc().toIso8601String(),
      "valid_until": validUntil.toUtc().toIso8601String(),
      "is_active": isActive,
    });
  }

  Future<void> deleteCoupon(String id) async {
    await _dio.delete("/admin/coupons/$id");
  }

  Future<List<CouponModel>> listCoupons() async {
    final response = await _dio.get("/admin/coupons");
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => CouponModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- Payments ----

  Future<List<PaymentModel>> listPayments({int limit = 20, int offset = 0}) async {
    final response = await _dio.get("/admin/payments", queryParameters: {
      "limit": limit,
      "offset": offset,
    });
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refundPayment(String id) async {
    await _dio.post("/admin/payments/$id/refund");
  }

  // ---- Reports ----

  Future<RevenueReportModel> getRevenueReport() async {
    final response = await _dio.get("/admin/reports/revenue");
    final data = response.data["data"] as Map<String, dynamic>;
    return RevenueReportModel.fromJson(data);
  }

  Future<StudentsReportModel> getStudentsReport() async {
    final response = await _dio.get("/admin/reports/students");
    final data = response.data["data"] as Map<String, dynamic>;
    return StudentsReportModel.fromJson(data);
  }

  Future<CoursesReportModel> getCoursesReport() async {
    final response = await _dio.get("/admin/reports/courses");
    final data = response.data["data"] as Map<String, dynamic>;
    return CoursesReportModel.fromJson(data);
  }

  // ---- Settings ----

  Future<List<AppSettingModel>> getSettings() async {
    final response = await _dio.get("/admin/settings");
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => AppSettingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> setSetting({required String key, required String value}) async {
    await _dio.put("/admin/settings/$key", data: {"value": value});
  }

  // ---- Banners ----

  Future<BannerModel> createBanner({
    required String title,
    required String imageUrl,
    String linkUrl = "",
    int displayOrder = 0,
  }) async {
    final response = await _dio.post("/admin/banners", data: {
      "title": title,
      "image_url": imageUrl,
      "link_url": linkUrl,
      "display_order": displayOrder,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return BannerModel.fromJson(data);
  }

  Future<void> updateBanner({
    required String id,
    required String title,
    required String imageUrl,
    String linkUrl = "",
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    await _dio.put("/admin/banners/$id", data: {
      "title": title,
      "image_url": imageUrl,
      "link_url": linkUrl,
      "display_order": displayOrder,
      "is_active": isActive,
    });
  }

  Future<void> deleteBanner(String id) async {
    await _dio.delete("/admin/banners/$id");
  }

  Future<List<BannerModel>> listBanners() async {
    final response = await _dio.get("/admin/banners");
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
