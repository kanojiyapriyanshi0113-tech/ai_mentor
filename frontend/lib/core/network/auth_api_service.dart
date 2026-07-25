import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';

class AuthResult {
  final String token;
  final UserModel user;

  AuthResult({required this.token, required this.user});
}

class AuthApiService {
  final Dio _dio = ApiClient().dio;
  final SecureStorageService _storage = SecureStorageService();

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromApiJson(data['user'] as Map<String, dynamic>);

    await _storage.saveToken(token);
    return AuthResult(token: token, user: user);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromApiJson(data['user'] as Map<String, dynamic>);

    await _storage.saveToken(token);
    return AuthResult(token: token, user: user);
  }

  Future<void> forgotPassword({required String email}) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  /// Extracts a human-readable error message from a DioException,
  /// falling back to a generic message if the backend didn't send one.
  static String extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null && data['error']['message'] != null) {
        return data['error']['message'] as String;
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
