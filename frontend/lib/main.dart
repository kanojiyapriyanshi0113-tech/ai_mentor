import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "core/providers/course_provider.dart";
import "core/providers/subscription_provider.dart";
import "core/providers/user_provider.dart";
import "core/router/app_router.dart";
import "core/theme/app_theme.dart";

void main() {
  runApp(const AIMentorApp());
}

class AIMentorApp extends StatelessWidget {
  const AIMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],
      child: MaterialApp.router(
        title: "AI Mentor",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}