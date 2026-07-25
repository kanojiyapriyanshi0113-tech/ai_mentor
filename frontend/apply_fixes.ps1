# Fix teacher/admin build errors - run this from PowerShell
# BOM-safe version: files clean UTF-8 (no BOM) me likhta hai .NET writer se

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib\features\teacher\presentation\providers\teacher_provider.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/teacher_models.dart';
import '../../../../core/network/teacher_api_service.dart';

enum LoadStatus { idle, loading, success, error }

class TeacherProvider extends ChangeNotifier {
  final TeacherApiService _api = TeacherApiService();

  LoadStatus dashboardStatus = LoadStatus.idle;
  String? errorMessage;
  TeacherDashboardModel? dashboard;

  LoadStatus batchesStatus = LoadStatus.idle;
  List<BatchModel> batches = [];

  LoadStatus subjectsStatus = LoadStatus.idle;
  List<SubjectModel> subjects = [];

  LoadStatus chaptersStatus = LoadStatus.idle;
  List<ChapterModel> chapters = [];

  LoadStatus lecturesStatus = LoadStatus.idle;
  List<LectureModel> lectures = [];

  LoadStatus pdfsStatus = LoadStatus.idle;
  List<PdfModel> pdfs = [];

  LoadStatus mockTestsStatus = LoadStatus.idle;
  List<MockTestModel> mockTests = [];

  LoadStatus pyqsStatus = LoadStatus.idle;
  List<PyqModel> pyqs = [];

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

  // ---- Batches ----

  Future<bool> createBatch({
    required int examId,
    required String title,
    String description = '',
    String thumbnail = '',
  }) async {
    batchesStatus = LoadStatus.loading;
    notifyListeners();
    try {
      final batch = await _api.createBatch(
        examId: examId,
        title: title,
        description: description,
        thumbnail: thumbnail,
      );
      batches = [...batches, batch];
      batchesStatus = LoadStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      batchesStatus = LoadStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBatch({
    required String id,
    required String title,
    String description = '',
    String thumbnail = '',
    bool isActive = true,
  }) async {
    try {
      await _api.updateBatch(
        id: id,
        title: title,
        description: description,
        thumbnail: thumbnail,
        isActive: isActive,
      );
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBatch(String id) async {
    try {
      await _api.deleteBatch(id);
      batches = batches.where((b) => b.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> publishBatch({required String id, required bool publish}) async {
    try {
      await _api.publishBatch(id: id, publish: publish);
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Subjects ----

  Future<bool> createSubject({
    required String batchId,
    required String name,
    String icon = '',
    int displayOrder = 0,
  }) async {
    try {
      final subject = await _api.createSubject(
        batchId: batchId,
        name: name,
        icon: icon,
        displayOrder: displayOrder,
      );
      subjects = [...subjects, subject];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    try {
      await _api.deleteSubject(id);
      subjects = subjects.where((s) => s.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Chapters ----

  Future<bool> createChapter({
    required String subjectId,
    required String title,
    String description = '',
    int displayOrder = 0,
  }) async {
    try {
      final chapter = await _api.createChapter(
        subjectId: subjectId,
        title: title,
        description: description,
        displayOrder: displayOrder,
      );
      chapters = [...chapters, chapter];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChapter(String id) async {
    try {
      await _api.deleteChapter(id);
      chapters = chapters.where((c) => c.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> reorderChapters({required String subjectId, required List<String> orderedIds}) async {
    try {
      await _api.reorderChapters(subjectId: subjectId, orderedIds: orderedIds);
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Lectures ----

  Future<bool> createLecture({
    required String chapterId,
    required String title,
    required String videoUrl,
    String description = '',
    int durationMinutes = 0,
    bool isPreview = false,
    int displayOrder = 0,
  }) async {
    try {
      final lecture = await _api.createLecture(
        chapterId: chapterId,
        title: title,
        videoUrl: videoUrl,
        description: description,
        durationMinutes: durationMinutes,
        isPreview: isPreview,
        displayOrder: displayOrder,
      );
      lectures = [...lectures, lecture];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLecture(String id) async {
    try {
      await _api.deleteLecture(id);
      lectures = lectures.where((l) => l.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- PDFs ----

  Future<bool> uploadPdf({
    required String chapterId,
    required String title,
    required String fileUrl,
    int displayOrder = 0,
  }) async {
    try {
      final pdf = await _api.uploadPdf(
        chapterId: chapterId,
        title: title,
        fileUrl: fileUrl,
        displayOrder: displayOrder,
      );
      pdfs = [...pdfs, pdf];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePdf(String id) async {
    try {
      await _api.deletePdf(id);
      pdfs = pdfs.where((p) => p.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Mock tests ----

  Future<bool> createMockTest({
    required String batchId,
    required String title,
    int durationMinutes = 0,
    int totalQuestions = 0,
  }) async {
    try {
      final test = await _api.createMockTest(
        batchId: batchId,
        title: title,
        durationMinutes: durationMinutes,
        totalQuestions: totalQuestions,
      );
      mockTests = [...mockTests, test];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMockTest(String id) async {
    try {
      await _api.deleteMockTest(id);
      mockTests = mockTests.where((m) => m.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- PYQs ----

  Future<bool> uploadPyq({
    required String batchId,
    required String examName,
    required int year,
    required String fileUrl,
    String subjectTag = '',
  }) async {
    try {
      final pyq = await _api.uploadPyq(
        batchId: batchId,
        examName: examName,
        year: year,
        fileUrl: fileUrl,
        subjectTag: subjectTag,
      );
      pyqs = [...pyqs, pyq];
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePyq(String id) async {
    try {
      await _api.deletePyq(id);
      pyqs = pyqs.where((p) => p.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Live classes ----

  Future<bool> createLiveClass({
    required String batchId,
    required String title,
    required DateTime scheduledAt,
    String meetingUrl = '',
  }) async {
    try {
      await _api.createLiveClass(
        batchId: batchId,
        title: title,
        scheduledAt: scheduledAt,
        meetingUrl: meetingUrl,
      );
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }

  // ---- Notifications ----

  Future<bool> sendNotification({
    required String batchId,
    required String title,
    required String message,
  }) async {
    try {
      await _api.sendNotification(batchId: batchId, title: title, message: message);
      return true;
    } catch (e) {
      errorMessage = _errorFrom(e);
      notifyListeners();
      return false;
    }
  }
}
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib\features\admin\presentation\providers\admin_provider.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
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
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib\core\storage\secure_storage_service.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';
  static const _onboardingDoneKey = 'onboarding_done';
  static const _examSelectedKey = 'exam_selected';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> saveRole(String role) => _storage.write(key: _roleKey, value: role);

  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> deleteRole() => _storage.delete(key: _roleKey);

  Future<void> setOnboardingDone() => _storage.write(key: _onboardingDoneKey, value: 'true');

  Future<bool> isOnboardingDone() async {
    final value = await _storage.read(key: _onboardingDoneKey);
    return value == 'true';
  }

  Future<void> setExamSelected() => _storage.write(key: _examSelectedKey, value: 'true');

  Future<bool> isExamSelected() async {
    final value = await _storage.read(key: _examSelectedKey);
    return value == 'true';
  }
}
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\test\widget_test.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
// This is a basic Flutter widget smoke test for AI Mentor.
//
// It verifies the app boots and renders a MaterialApp without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AIMentorApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib\main.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "core/providers/course_provider.dart";
import "core/providers/subscription_provider.dart";
import "core/providers/user_provider.dart";
import "core/router/app_router.dart";
import "core/theme/app_theme.dart";
import "features/admin/presentation/providers/admin_provider.dart";
import "features/teacher/presentation/providers/teacher_provider.dart";

void main() {
  runApp(const AIMentorApp());
}

class AIMentorApp extends StatelessWidget {
  const AIMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: "AI Mentor",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"
