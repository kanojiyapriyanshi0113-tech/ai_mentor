import "package:dio/dio.dart";

import "../models/teacher_models.dart";
import "api_client.dart";

/// API service for the teacher module (/api/teacher/*).
/// Requires the caller to hold a JWT with role "teacher" — enforced
/// server-side by RequireTeacher() middleware.
class TeacherApiService {
  final Dio _dio = ApiClient().dio;

  Future<TeacherDashboardModel> getDashboard() async {
    final response = await _dio.get("/teacher/dashboard");
    final data = response.data["data"] as Map<String, dynamic>;
    return TeacherDashboardModel.fromJson(data);
  }

  // ---- Batches ----

  Future<BatchModel> createBatch({
    required int examId,
    required String title,
    String description = "",
    String thumbnail = "",
  }) async {
    final response = await _dio.post("/teacher/batches", data: {
      "exam_id": examId,
      "title": title,
      "description": description,
      "thumbnail": thumbnail,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return BatchModel.fromJson(data);
  }

  Future<void> updateBatch({
    required String id,
    required String title,
    String description = "",
    String thumbnail = "",
    bool isActive = true,
  }) async {
    await _dio.put("/teacher/batches/$id", data: {
      "title": title,
      "description": description,
      "thumbnail": thumbnail,
      "is_active": isActive,
    });
  }

  Future<void> deleteBatch(String id) async {
    await _dio.delete("/teacher/batches/$id");
  }

  Future<void> publishBatch({required String id, required bool publish}) async {
    await _dio.patch("/teacher/batches/$id/publish", data: {"publish": publish});
  }

  // ---- Subjects ----

  Future<SubjectModel> createSubject({
    required String batchId,
    required String name,
    String icon = "",
    int displayOrder = 0,
  }) async {
    final response = await _dio.post("/teacher/subjects", data: {
      "batch_id": batchId,
      "name": name,
      "icon": icon,
      "display_order": displayOrder,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return SubjectModel.fromJson(data);
  }

  Future<void> updateSubject({
    required String id,
    required String name,
    String icon = "",
    int displayOrder = 0,
  }) async {
    await _dio.put("/teacher/subjects/$id", data: {
      "name": name,
      "icon": icon,
      "display_order": displayOrder,
    });
  }

  Future<void> deleteSubject(String id) async {
    await _dio.delete("/teacher/subjects/$id");
  }

  // ---- Chapters ----

  Future<ChapterModel> createChapter({
    required String subjectId,
    required String title,
    String description = "",
    int displayOrder = 0,
  }) async {
    final response = await _dio.post("/teacher/chapters", data: {
      "subject_id": subjectId,
      "title": title,
      "description": description,
      "display_order": displayOrder,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return ChapterModel.fromJson(data);
  }

  Future<void> updateChapter({
    required String id,
    required String title,
    String description = "",
    int displayOrder = 0,
  }) async {
    await _dio.put("/teacher/chapters/$id", data: {
      "title": title,
      "description": description,
      "display_order": displayOrder,
    });
  }

  Future<void> deleteChapter(String id) async {
    await _dio.delete("/teacher/chapters/$id");
  }

  Future<void> reorderChapters({
    required String subjectId,
    required List<String> orderedIds,
  }) async {
    await _dio.patch("/teacher/subjects/$subjectId/chapters/reorder", data: {
      "ordered_ids": orderedIds,
    });
  }

  // ---- Lectures ----

  Future<LectureModel> createLecture({
    required String chapterId,
    required String title,
    required String videoUrl,
    String description = "",
    int durationMinutes = 0,
    bool isPreview = false,
    int displayOrder = 0,
  }) async {
    final response = await _dio.post("/teacher/lectures", data: {
      "chapter_id": chapterId,
      "title": title,
      "description": description,
      "duration_minutes": durationMinutes,
      "video_url": videoUrl,
      "is_preview": isPreview,
      "display_order": displayOrder,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return LectureModel.fromJson(data);
  }

  Future<void> updateLecture({
    required String id,
    required String title,
    required String videoUrl,
    String description = "",
    int durationMinutes = 0,
    bool isPreview = false,
    int displayOrder = 0,
  }) async {
    await _dio.put("/teacher/lectures/$id", data: {
      "title": title,
      "description": description,
      "duration_minutes": durationMinutes,
      "video_url": videoUrl,
      "is_preview": isPreview,
      "display_order": displayOrder,
    });
  }

  Future<void> deleteLecture(String id) async {
    await _dio.delete("/teacher/lectures/$id");
  }

  // ---- PDFs ----

  Future<PdfModel> uploadPdf({
    required String chapterId,
    required String title,
    required String fileUrl,
    int displayOrder = 0,
  }) async {
    final response = await _dio.post("/teacher/pdfs", data: {
      "chapter_id": chapterId,
      "title": title,
      "file_url": fileUrl,
      "display_order": displayOrder,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return PdfModel.fromJson(data);
  }

  Future<void> replacePdf({required String id, required String fileUrl}) async {
    await _dio.put("/teacher/pdfs/$id", data: {"file_url": fileUrl});
  }

  Future<void> deletePdf(String id) async {
    await _dio.delete("/teacher/pdfs/$id");
  }

  Future<List<PdfModel>> listPdfs() async {
    final response = await _dio.get("/teacher/pdfs");
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => PdfModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- Mock tests ----

  Future<MockTestModel> createMockTest({
    required String batchId,
    required String title,
    int durationMinutes = 0,
    int totalQuestions = 0,
  }) async {
    final response = await _dio.post("/teacher/mocktests", data: {
      "batch_id": batchId,
      "title": title,
      "duration_minutes": durationMinutes,
      "total_questions": totalQuestions,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return MockTestModel.fromJson(data);
  }

  Future<void> updateMockTest({
    required String id,
    required String title,
    int durationMinutes = 0,
    int totalQuestions = 0,
  }) async {
    await _dio.put("/teacher/mocktests/$id", data: {
      "title": title,
      "duration_minutes": durationMinutes,
      "total_questions": totalQuestions,
    });
  }

  Future<void> deleteMockTest(String id) async {
    await _dio.delete("/teacher/mocktests/$id");
  }

  Future<List<MockTestModel>> listMockTests() async {
    final response = await _dio.get("/teacher/mocktests");
    final data = response.data["data"] as List<dynamic>;
    return data.map((e) => MockTestModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- PYQs ----

  Future<PyqModel> uploadPyq({
    required String batchId,
    required String examName,
    required int year,
    required String fileUrl,
    String subjectTag = "",
  }) async {
    final response = await _dio.post("/teacher/pyqs", data: {
      "batch_id": batchId,
      "exam_name": examName,
      "year": year,
      "subject_tag": subjectTag,
      "file_url": fileUrl,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return PyqModel.fromJson(data);
  }

  Future<void> updatePyq({
    required String id,
    required String examName,
    required int year,
    required String fileUrl,
    String subjectTag = "",
  }) async {
    await _dio.put("/teacher/pyqs/$id", data: {
      "exam_name": examName,
      "year": year,
      "subject_tag": subjectTag,
      "file_url": fileUrl,
    });
  }

  Future<void> deletePyq(String id) async {
    await _dio.delete("/teacher/pyqs/$id");
  }

  // ---- Live classes ----

  Future<LiveClassModel> createLiveClass({
    required String batchId,
    required String title,
    required DateTime scheduledAt,
    String meetingUrl = "",
  }) async {
    final response = await _dio.post("/teacher/live-classes", data: {
      "batch_id": batchId,
      "title": title,
      "scheduled_at": scheduledAt.toUtc().toIso8601String(),
      "meeting_url": meetingUrl,
    });
    final data = response.data["data"] as Map<String, dynamic>;
    return LiveClassModel.fromJson(data);
  }

  // ---- Notifications ----

  Future<void> sendNotification({
    required String batchId,
    required String title,
    required String message,
  }) async {
    await _dio.post("/teacher/notifications", data: {
      "batch_id": batchId,
      "title": title,
      "message": message,
    });
  }
}
