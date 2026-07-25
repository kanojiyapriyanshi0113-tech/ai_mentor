import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final token = await _storage.getToken();
    final onboardingDone = await _storage.isOnboardingDone();
    final examSelected = await _storage.isExamSelected();

    if (token == null) {
      context.go(onboardingDone ? AppRoutes.login : AppRoutes.onboarding);
      return;
    }

    context.go(examSelected ? AppRoutes.home : AppRoutes.examSelection);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 16),
            Text('AI Mentor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
