import 'package:dio/dio.dart';

import 'api_client.dart';

class ExamOption {
  final int id;
  final String code;
  final String name;
  final String category;

  ExamOption({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
  });

  factory ExamOption.fromJson(Map<String, dynamic> json) {
    return ExamOption(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
    );
  }
}

class ExamApiService {
  final Dio _dio = ApiClient().dio;

  Future<List<ExamOption>> listExams() async {
    final response = await _dio.get('/exams');
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => ExamOption.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExamOption> selectExam(int examId) async {
    final response = await _dio.post('/exams/select', data: {'exam_id': examId});
    final data = response.data['data'] as Map<String, dynamic>;
    return ExamOption(
      id: data['exam_id'] as int,
      code: data['code'] as String,
      name: data['name'] as String,
      category: data['category'] as String? ?? '',
    );
  }
}
