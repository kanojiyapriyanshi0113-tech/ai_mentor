import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  static const String baseUrl = 'http://192.168.1.18:8081/api';

  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService();

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer ' + token;
        }
        return handler.next(options);
      },
    ));
  }
}
