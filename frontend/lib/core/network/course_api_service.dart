import "package:dio/dio.dart";

import "api_client.dart";

class Batch {
  final String id;
  final int examId;
  final String title;
  final String description;
  final String thumbnail;
  final bool isActive;

  Batch({
    required this.id,
    required this.examId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.isActive,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json["id"] as String,
      examId: json["exam_id"] as int,
      title: json["title"] as String,
      description: (json["description"] ?? "") as String,
      thumbnail: (json["thumbnail"] ?? "") as String,
      isActive: json["is_active"] as bool,
    );
  }
}

class Subject {
  final String id;
  final String batchId;
  final String name;
  final String icon;
  final int displayOrder;

  Subject({
    required this.id,
    required this.batchId,
    required this.name,
    required this.icon,
    required this.displayOrder,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json["id"] as String,
      batchId: json["batch_id"] as String,
      name: json["name"] as String,
      icon: (json["icon"] ?? "") as String,
      displayOrder: json["display_order"] as int,
    );
  }
}

class Chapter {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final int displayOrder;

  Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.displayOrder,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json["id"] as String,
      subjectId: json["subject_id"] as String,
      title: json["title"] as String,
      description: (json["description"] ?? "") as String,
      displayOrder: json["display_order"] as int,
    );
  }
}

class Lecture {
  final String id;
  final String chapterId;
  final String title;
  final String description;
  final int durationMinutes;
  final String videoUrl;
  final bool isPreview;
  final int displayOrder;

  Lecture({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.videoUrl,
    required this.isPreview,
    required this.displayOrder,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json["id"] as String,
      chapterId: json["chapter_id"] as String,
      title: json["title"] as String,
      description: (json["description"] ?? "") as String,
      durationMinutes: json["duration_minutes"] as int,
      videoUrl: json["video_url"] as String,
      isPreview: json["is_preview"] as bool,
      displayOrder: json["display_order"] as int,
    );
  }
}

class LectureSummary {
  final String lectureId;
  final String lectureTitle;
  final String chapterId;
  final String chapterTitle;

  LectureSummary({
    required this.lectureId,
    required this.lectureTitle,
    required this.chapterId,
    required this.chapterTitle,
  });

  factory LectureSummary.fromJson(Map<String, dynamic> json) {
    return LectureSummary(
      lectureId: json["lecture_id"] as String,
      lectureTitle: json["lecture_title"] as String,
      chapterId: json["chapter_id"] as String,
      chapterTitle: json["chapter_title"] as String,
    );
  }
}

class BatchProgress {
  final int completedLectures;
  final int totalLectures;
  final int completedChapters;
  final int totalChapters;
  final double progressPercent;
  final LectureSummary? lastWatched;
  final LectureSummary? continueLearning;

  BatchProgress({
    required this.completedLectures,
    required this.totalLectures,
    required this.completedChapters,
    required this.totalChapters,
    required this.progressPercent,
    this.lastWatched,
    this.continueLearning,
  });

  factory BatchProgress.fromJson(Map<String, dynamic> json) {
    return BatchProgress(
      completedLectures: json["completed_lectures"] as int,
      totalLectures: json["total_lectures"] as int,
      completedChapters: json["completed_chapters"] as int,
      totalChapters: json["total_chapters"] as int,
      progressPercent: (json["progress_percent"] as num).toDouble(),
      lastWatched: json["last_watched"] == null
          ? null
          : LectureSummary.fromJson(json["last_watched"] as Map<String, dynamic>),
      continueLearning: json["continue_learning"] == null
          ? null
          : LectureSummary.fromJson(json["continue_learning"] as Map<String, dynamic>),
    );
  }
}
class CourseApiService {
  final Dio _dio = ApiClient().dio;

  Future<List<Batch>> listBatches() async {
    final response = await _dio.get("/course/batches");
    final list = response.data["data"] as List<dynamic>? ?? [];
    return list.map((e) => Batch.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Batch> getBatch(String batchId) async {
    final response = await _dio.get("/course/batches/$batchId");
    return Batch.fromJson(response.data["data"] as Map<String, dynamic>);
  }

  Future<List<Subject>> listSubjects(String batchId) async {
    final response = await _dio.get("/course/subjects/$batchId");
    final list = response.data["data"] as List<dynamic>? ?? [];
    return list.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Chapter>> listChapters(String subjectId) async {
    final response = await _dio.get("/course/chapters/$subjectId");
    final list = response.data["data"] as List<dynamic>? ?? [];
    return list.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Lecture>> listLectures(String chapterId) async {
    final response = await _dio.get("/course/lectures/$chapterId");
    final list = response.data["data"] as List<dynamic>? ?? [];
    return list.map((e) => Lecture.fromJson(e as Map<String, dynamic>)).toList();
  }
   Future<void> completeLecture(String lectureId) async {
    await _dio.post("/course/lectures/$lectureId/complete");
  }

  Future<BatchProgress> getBatchProgress(String batchId) async {
    final response = await _dio.get("/course/batches/$batchId/progress");
    return BatchProgress.fromJson(response.data["data"] as Map<String, dynamic>);
  }
}