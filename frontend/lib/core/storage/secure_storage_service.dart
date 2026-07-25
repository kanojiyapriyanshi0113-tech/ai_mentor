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