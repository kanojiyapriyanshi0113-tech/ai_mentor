import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/providers/course_provider.dart";
import "../../core/providers/user_provider.dart";
import "course_detail_screen.dart";
import "widgets/course_card.dart";

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int? _loadedExamId;
  bool _hasLoadedOnce = false;

  @override
  Widget build(BuildContext context) {
    final examId = context.watch<UserProvider>().currentUser?.selectedExamId;

    if (!_hasLoadedOnce || examId != _loadedExamId) {
      _hasLoadedOnce = true;
      _loadedExamId = examId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<CourseProvider>().loadBatches(examId: examId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Consumer<CourseProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingBatches) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.batchesError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.batchesError!, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final examId = context.read<UserProvider>().currentUser?.selectedExamId;
                        provider.loadBatches(examId: examId);
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }
            final batches = provider.batches;
            if (batches.isEmpty) {
              return Center(
                child: Text("No courses enrolled yet", style: TextStyle(color: Colors.grey[600])),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: batches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final batch = batches[index];
                return CourseCard(
                  batch: batch,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(batch: batch),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
