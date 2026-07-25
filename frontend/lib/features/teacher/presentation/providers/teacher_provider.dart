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