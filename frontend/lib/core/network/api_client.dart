import "package:dio/dio.dart";

import "../navigation/navigation_service.dart";
import "../storage/secure_storage_service.dart";
import "../widgets/premium_bottom_sheet.dart";

const String kBaseUrl = "http://192.168.1.29:8081/api";

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storageService = SecureStorageService();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          final isSubscriptionLimitError = e.response?.statusCode == 402;

          if (isSubscriptionLimitError) {
            final context = rootNavigatorKey.currentContext;
            if (context != null) {
              showPremiumBottomSheet(context);
            }
          }

          handler.next(e);
        },
      ),
    );
  }
}
