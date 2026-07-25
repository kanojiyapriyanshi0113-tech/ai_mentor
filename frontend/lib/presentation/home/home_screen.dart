import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:provider/provider.dart";

import "../../core/providers/course_provider.dart";
import "../../core/providers/subscription_provider.dart";
import "../../core/providers/user_provider.dart";
import "../../core/router/app_routes.dart";
import "widgets/continue_learning_card.dart";
import "widgets/daily_goal_card.dart";
import "widgets/feature_access_section.dart";
import "widgets/greeting_header.dart";
import "widgets/latest_updates_section.dart";
import "widgets/quick_actions_section.dart";
import "widgets/recommended_courses_section.dart";
import "widgets/study_streak_card.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<SubscriptionProvider>().loadFeatures();
      await _loadContinueLearning();
    });
  }

  Future<void> _loadContinueLearning() async {
    final courseProvider = context.read<CourseProvider>();
    await courseProvider.loadBatches();
    if (!mounted) return;
    if (courseProvider.batches.isNotEmpty) {
      final firstBatchId = courseProvider.batches.first.id;
      await courseProvider.loadBatchProgress(firstBatchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final features = context.watch<SubscriptionProvider>().features;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Mentor"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: "Profile",
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GreetingHeader(userName: user?.name ?? "Aspirant"),
            const SizedBox(height: 20),
            const ContinueLearningCard(),
            const SizedBox(height: 16),
            const DailyGoalCard(),
            const SizedBox(height: 16),
            const StudyStreakCard(),
            const SizedBox(height: 24),
            QuickActionsSection(features: features),
            const SizedBox(height: 24),
            const FeatureAccessSection(),
            const SizedBox(height: 24),
            const LatestUpdatesSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
