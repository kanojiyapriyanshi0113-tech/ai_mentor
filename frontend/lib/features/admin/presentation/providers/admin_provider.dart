import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/admin_models.dart';
import '../../../../core/network/admin_api_service.dart';

enum LoadStatus { idle, loading, success, error }

class AdminProvider extends ChangeNotifier {
  final AdminApiService _api = AdminApiService();

  LoadStatus dashboardStatus = LoadStatus.idle;
  String? errorMessage;
  AdminDashboardModel? dashboard;

  LoadStatus teachersStatus = LoadStatus.idle;
  List<TeacherAccountModel> teachers = [];

  LoadStatus studentsStatus = LoadStatus.idle;
  List<StudentAccountModel> students = [];

  LoadStatus plansStatus = LoadStatus.idle;
  List<AdminPlanModel> plans = [];

  LoadStatus planCatalogStatus = LoadStatus.idle;
  List<PlanCatalogModel> planCatalog = [];

  LoadStatus couponsStatus = LoadStatus.idle;
  List<CouponModel> coupons = [];

  LoadStatus paymentsStatus = LoadStatus.idle;
  List<PaymentModel> payments = [];

  LoadStatus settingsStatus = LoadStatus.idle;
  List<AppSettingModel> settings = [];

  LoadStatus bannersStatus = LoadStatus.idle;
  List<BannerModel> banners = [];

  RevenueReportModel? revenueReport;
  StudentsReportModel? studentsReport;
  CoursesReportModel? coursesReport;

  String _errorFrom(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) return data['message'] as String;
    }
    return 'Something went wrong';
  }

  Future<void> loadDashboard() async {
    dashboardStatus = LoadStatus.loading;
    notifyListeners();
    try {
      dashboard = await _api.getDashboard();
      dashboardStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      dashboardStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  // ---- Teachers ----

  Future<void> loadTeachers() async {
    teachersStatus = LoadStatus.loading;
    notifyListeners();
    try {
      teachers = await _api.listTeachers();
      teachersStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      teachersStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addTeacher({required String name, required String email, required String password}) async {
    try {
      final t = await _api.addTeacher(name: name, email: email, password: password);
      teachers = [...teachers, t];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveTeacher(String id) async {
    try {
      await _api.approveTeacher(id);
      await loadTeachers();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> editTeacher({required String id, required String name, required String email}) async {
    try {
      await _api.editTeacher(id: id, name: name, email: email);
      await loadTeachers();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> suspendTeacher({required String id, required bool suspend}) async {
    try {
      await _api.suspendTeacher(id: id, suspend: suspend);
      await loadTeachers();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTeacher(String id) async {
    try {
      await _api.deleteTeacher(id);
      teachers = teachers.where((t) => t.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Students ----

  Future<void> loadStudents({String search = '', int limit = 20, int offset = 0}) async {
    studentsStatus = LoadStatus.loading;
    notifyListeners();
    try {
      students = await _api.listStudents(search: search, limit: limit, offset: offset);
      studentsStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      studentsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> blockStudent({required String id, required bool block}) async {
    try {
      await _api.blockStudent(id: id, block: block);
      await loadStudents();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await _api.deleteStudent(id);
      students = students.where((s) => s.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Plans ----

  Future<bool> createPlan({
    required String code,
    required String name,
    required int durationDays,
    int pricePaise = 0,
    bool isTrial = false,
  }) async {
    try {
      final plan = await _api.createPlan(
        code: code,
        name: name,
        durationDays: durationDays,
        pricePaise: pricePaise,
        isTrial: isTrial,
      );
      plans = [...plans, plan];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> setPlanActive({required int id, required bool active}) async {
    try {
      if (active) {
        await _api.enablePlan(id);
      } else {
        await _api.disablePlan(id);
      }
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> loadPlanCatalog() async {
    planCatalogStatus = LoadStatus.loading;
    notifyListeners();
    try {
      planCatalog = await _api.listPlanCatalog();
      planCatalogStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      planCatalogStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  // ---- Coupons ----

  Future<void> loadCoupons() async {
    couponsStatus = LoadStatus.loading;
    notifyListeners();
    try {
      coupons = await _api.listCoupons();
      couponsStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      couponsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createCoupon({
    required String code,
    required DateTime validUntil,
    int discountPercent = 0,
    int discountAmountPaise = 0,
    int maxUses = 0,
    DateTime? validFrom,
  }) async {
    try {
      final coupon = await _api.createCoupon(
        code: code,
        validUntil: validUntil,
        discountPercent: discountPercent,
        discountAmountPaise: discountAmountPaise,
        maxUses: maxUses,
        validFrom: validFrom,
      );
      coupons = [...coupons, coupon];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCoupon(String id) async {
    try {
      await _api.deleteCoupon(id);
      coupons = coupons.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Payments ----

  Future<void> loadPayments({int limit = 20, int offset = 0}) async {
    paymentsStatus = LoadStatus.loading;
    notifyListeners();
    try {
      payments = await _api.listPayments(limit: limit, offset: offset);
      paymentsStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      paymentsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> refundPayment(String id) async {
    try {
      await _api.refundPayment(id);
      await loadPayments();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Reports ----

  Future<void> loadReports() async {
    try {
      revenueReport = await _api.getRevenueReport();
      studentsReport = await _api.getStudentsReport();
      coursesReport = await _api.getCoursesReport();
      notifyListeners();
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
    }
  }

  // ---- Settings ----

  Future<void> loadSettings() async {
    settingsStatus = LoadStatus.loading;
    notifyListeners();
    try {
      settings = await _api.getSettings();
      settingsStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      settingsStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> setSetting({required String key, required String value}) async {
    try {
      await _api.setSetting(key: key, value: value);
      await loadSettings();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Banners ----

  Future<void> loadBanners() async {
    bannersStatus = LoadStatus.loading;
    notifyListeners();
    try {
      banners = await _api.listBanners();
      bannersStatus = LoadStatus.success;
    } catch (e) {
      errorMessage = _errorFrom(e);
      bannersStatus = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> createBanner({
    required String title,
    required String imageUrl,
    String linkUrl = '',
    int displayOrder = 0,
  }) async {
    try {
      final banner = await _api.createBanner(
        title: title,
        imageUrl: imageUrl,
        linkUrl: linkUrl,
        displayOrder: displayOrder,
      );
      banners = [...banners, banner];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBanner(String id) async {
    try {
      await _api.deleteBanner(id);
      banners = banners.where((b) => b.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }
}