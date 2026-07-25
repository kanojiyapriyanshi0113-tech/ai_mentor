import "package:flutter/material.dart";

import "../network/course_api_service.dart";

class CourseProvider extends ChangeNotifier {
  final CourseApiService _service = CourseApiService();

  List<Batch> _batches = [];
  bool _isLoadingBatches = false;
  String? _batchesError;

  List<Subject> _subjects = [];
  bool _isLoadingSubjects = false;
  String? _subjectsError;

  List<Chapter> _chapters = [];
  bool _isLoadingChapters = false;
  String? _chaptersError;

  List<Lecture> _lectures = [];
  bool _isLoadingLectures = false;
  String? _lecturesError;

  BatchProgress? _batchProgress;
  bool _isLoadingProgress = false;
  String? _progressError;

  List<Batch> get batches => _batches;
  bool get isLoadingBatches => _isLoadingBatches;
  String? get batchesError => _batchesError;

  List<Subject> get subjects => _subjects;
  bool get isLoadingSubjects => _isLoadingSubjects;
  String? get subjectsError => _subjectsError;

  List<Chapter> get chapters => _chapters;
  bool get isLoadingChapters => _isLoadingChapters;
  String? get chaptersError => _chaptersError;

  List<Lecture> get lectures => _lectures;
  bool get isLoadingLectures => _isLoadingLectures;
  String? get lecturesError => _lecturesError;

  BatchProgress? get batchProgress => _batchProgress;
  bool get isLoadingProgress => _isLoadingProgress;
  String? get progressError => _progressError;

  Future<void> loadBatches({int? examId}) async {
    _isLoadingBatches = true;
    _batchesError = null;
    notifyListeners();

    try {
      final all = await _service.listBatches();
      _batches = examId == null ? all : all.where((b) => b.examId == examId).toList();
    } catch (e) {
      _batchesError = "Failed to load courses.";
    } finally {
      _isLoadingBatches = false;
      notifyListeners();
    }
  }

  Future<void> loadSubjects(String batchId) async {
    _isLoadingSubjects = true;
    _subjectsError = null;
    _subjects = [];
    notifyListeners();

    try {
      _subjects = await _service.listSubjects(batchId);
    } catch (e) {
      _subjectsError = "Failed to load subjects.";
    } finally {
      _isLoadingSubjects = false;
      notifyListeners();
    }
  }

  Future<void> loadChapters(String subjectId) async {
    _isLoadingChapters = true;
    _chaptersError = null;
    _chapters = [];
    notifyListeners();

    try {
      _chapters = await _service.listChapters(subjectId);
    } catch (e) {
      _chaptersError = "Failed to load chapters.";
    } finally {
      _isLoadingChapters = false;
      notifyListeners();
    }
  }

  Future<void> loadLectures(String chapterId) async {
    _isLoadingLectures = true;
    _lecturesError = null;
    _lectures = [];
    notifyListeners();

    try {
      _lectures = await _service.listLectures(chapterId);
    } catch (e) {
      _lecturesError = "Failed to load lectures.";
    } finally {
      _isLoadingLectures = false;
      notifyListeners();
    }
  }

  Future<void> loadBatchProgress(String batchId) async {
    _isLoadingProgress = true;
    _progressError = null;
    notifyListeners();

    try {
      _batchProgress = await _service.getBatchProgress(batchId);
    } catch (e) {
      _progressError = "Failed to load progress.";
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  Future<bool> completeLecture(String lectureId, String batchId) async {
    try {
      await _service.completeLecture(lectureId);
      await loadBatchProgress(batchId);
      return true;
    } catch (e) {
      return false;
    }
  }

  void clear() {
    _batches = [];
    _subjects = [];
    _chapters = [];
    _lectures = [];
    _batchProgress = null;
    notifyListeners();
  }
}
