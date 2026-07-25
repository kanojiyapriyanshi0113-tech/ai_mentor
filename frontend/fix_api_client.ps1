# Run this from: C:\Users\ABC\Desktop\AI_Mentor\frontend
# Usage:  .\fix_api_client.ps1

$ErrorActionPreference = "Stop"

$apiClientContent = @'
import "package:dio/dio.dart";

import "../navigation/navigation_service.dart";
import "../storage/secure_storage_service.dart";
import "../widgets/premium_bottom_sheet.dart";

const String kBaseUrl = "http://192.168.1.18:8081/api";

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
          // Only show the upgrade sheet for actual subscription/feature-limit
          // errors (HTTP 402 Payment Required), not for every API error
          // (login failures, network timeouts, 500s, etc).
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
'@
[System.IO.File]::WriteAllText("$PWD\lib\core\network\api_client.dart", $apiClientContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "Wrote api_client.dart"

Write-Host ""
Write-Host "Verifying..."
Select-String -Path "lib\core\network\api_client.dart" -Pattern "statusCode == 402"

Write-Host ""
Write-Host "Now run: flutter analyze"
