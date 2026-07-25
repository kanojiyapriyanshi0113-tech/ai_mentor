class BatchModel {
  final String id;
  final int examId;
  final String title;
  final String description;
  final String thumbnail;
  final bool isActive;
  final DateTime createdAt;

  BatchModel({
    required this.id,
    required this.examId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.isActive,
    required this.createdAt,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
        id: json['id'] as String,
        examId: json['exam_id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class SubjectModel {
  final String id;
  final String batchId;
  final String name;
  final String icon;
  final int displayOrder;

  SubjectModel({
    required this.id,
    required this.batchId,
    required this.name,
    required this.icon,
    required this.displayOrder,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'] as String,
        batchId: json['batch_id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? '',
        displayOrder: json['display_order'] as int? ?? 0,
      );
}

class ChapterModel {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final int displayOrder;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.displayOrder,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
        id: json['id'] as String,
        subjectId: json['subject_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        displayOrder: json['display_order'] as int? ?? 0,
      );
}

class LectureModel {
  final String id;
  final String chapterId;
  final String title;
  final String description;
  final int durationMinutes;
  final String videoUrl;
  final bool isPreview;
  final int displayOrder;

  LectureModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.videoUrl,
    required this.isPreview,
    required this.displayOrder,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) => LectureModel(
        id: json['id'] as String,
        chapterId: json['chapter_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        durationMinutes: json['duration_minutes'] as int? ?? 0,
        videoUrl: json['video_url'] as String? ?? '',
        isPreview: json['is_preview'] as bool? ?? false,
        displayOrder: json['display_order'] as int? ?? 0,
      );
}

class PdfModel {
  final String id;
  final String chapterId;
  final String title;
  final String fileUrl;
  final int displayOrder;

  PdfModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.fileUrl,
    required this.displayOrder,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) => PdfModel(
        id: json['id'] as String,
        chapterId: json['chapter_id'] as String,
        title: json['title'] as String,
        fileUrl: json['file_url'] as String,
        displayOrder: json['display_order'] as int? ?? 0,
      );
}

class MockTestModel {
  final String id;
  final String batchId;
  final String title;
  final int durationMinutes;
  final int totalQuestions;

  MockTestModel({
    required this.id,
    required this.batchId,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
  });

  factory MockTestModel.fromJson(Map<String, dynamic> json) => MockTestModel(
        id: json['id'] as String,
        batchId: json['batch_id'] as String,
        title: json['title'] as String,
        durationMinutes: json['duration_minutes'] as int? ?? 0,
        totalQuestions: json['total_questions'] as int? ?? 0,
      );
}

class PyqModel {
  final String id;
  final String batchId;
  final String examName;
  final int year;
  final String subjectTag;
  final String fileUrl;

  PyqModel({
    required this.id,
    required this.batchId,
    required this.examName,
    required this.year,
    required this.subjectTag,
    required this.fileUrl,
  });

  factory PyqModel.fromJson(Map<String, dynamic> json) => PyqModel(
        id: json['id'] as String,
        batchId: json['batch_id'] as String,
        examName: json['exam_name'] as String,
        year: json['year'] as int,
        subjectTag: json['subject_tag'] as String? ?? '',
        fileUrl: json['file_url'] as String,
      );
}

class LiveClassModel {
  final String id;
  final String batchId;
  final String title;
  final DateTime scheduledAt;
  final String meetingUrl;

  LiveClassModel({
    required this.id,
    required this.batchId,
    required this.title,
    required this.scheduledAt,
    required this.meetingUrl,
  });

  factory LiveClassModel.fromJson(Map<String, dynamic> json) => LiveClassModel(
        id: json['id'] as String,
        batchId: json['batch_id'] as String,
        title: json['title'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        meetingUrl: json['meeting_url'] as String? ?? '',
      );
}

class TeacherDashboardModel {
  final int totalStudents;
  final int totalBatches;
  final int totalSubjects;
  final int totalChapters;
  final int totalLectures;
  final int totalPdfs;
  final int totalMockTests;
  final List<LiveClassModel> upcomingLiveClasses;

  TeacherDashboardModel({
    required this.totalStudents,
    required this.totalBatches,
    required this.totalSubjects,
    required this.totalChapters,
    required this.totalLectures,
    required this.totalPdfs,
    required this.totalMockTests,
    required this.upcomingLiveClasses,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    final liveClasses = (json['upcoming_live_classes'] as List<dynamic>? ?? [])
        .map((e) => LiveClassModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return TeacherDashboardModel(
      totalStudents: json['total_students'] as int? ?? 0,
      totalBatches: json['total_batches'] as int? ?? 0,
      totalSubjects: json['total_subjects'] as int? ?? 0,
      totalChapters: json['total_chapters'] as int? ?? 0,
      totalLectures: json['total_lectures'] as int? ?? 0,
      totalPdfs: json['total_pdfs'] as int? ?? 0,
      totalMockTests: json['total_mock_tests'] as int? ?? 0,
      upcomingLiveClasses: liveClasses,
    );
  }
}
