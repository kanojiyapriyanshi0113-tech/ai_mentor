import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class AuthApiException implements Exception {
  final String message;
  AuthApiException(this.message);
}

class AuthRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthApiException(_extractError(e));
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AuthApiException(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null && data['error']['message'] != null) {
      return data['error']['message'].toString();
    }
    return 'Network error. Please try again.';
  }
}
