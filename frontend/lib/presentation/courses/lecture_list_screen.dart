import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/network/course_api_service.dart";
import "../../core/providers/course_provider.dart";
import "widgets/lecture_list.dart";

class LectureListScreen extends StatefulWidget {
  final Chapter chapter;
  final String batchId;

  const LectureListScreen({super.key, required this.chapter, required this.batchId});

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadLectures(widget.chapter.id);
    });
  }

  Future<void> _onTapLecture(Lecture lecture) async {
    final provider = context.read<CourseProvider>();
    final success = await provider.completeLecture(lecture.id, widget.batchId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Marked \"${lecture.title}\" as complete" : "Failed to update progress"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.title)),
      body: SafeArea(
        child: Consumer<CourseProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingLectures) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.lecturesError != null) {
              return Center(
                child: Text(provider.lecturesError!, style: TextStyle(color: Colors.grey[600])),
              );
            }
            if (provider.lectures.isEmpty) {
              return Center(
                child: Text("No lectures available", style: TextStyle(color: Colors.grey[600])),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: provider.lectures.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lecture = provider.lectures[index];
                return LectureTile(
                  lecture: lecture,
                  onTap: () => _onTapLecture(lecture),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
