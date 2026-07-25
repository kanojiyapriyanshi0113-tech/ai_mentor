import 'package:flutter/material.dart';
import '../../data/auth_remote_data_source.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/jwt_decoder.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthRemoteDataSource _dataSource = AuthRemoteDataSource();
  final SecureStorageService _storage = SecureStorageService();

  AuthStatus status = AuthStatus.idle;
  String? errorMessage;
  String? role;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _dataSource.register(name: name, email: email, password: password);
      final token = data['token'] as String;
      await _storage.saveToken(token);
      role = JwtDecoder.role(token) ?? 'student';
      await _storage.saveRole(role!);
      status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthApiException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _dataSource.login(email: email, password: password);
      final token = data['token'] as String;
      await _storage.saveToken(token);
      role = JwtDecoder.role(token) ?? 'student';
      await _storage.saveRole(role!);
      status = AuthStatus.success;
      notifyListeners();
      return true;
    } on AuthApiException catch (e) {
      errorMessage = e.message;
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }
}
