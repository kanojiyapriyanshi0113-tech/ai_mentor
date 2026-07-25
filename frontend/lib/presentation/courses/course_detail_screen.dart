import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/network/course_api_service.dart";
import "../../core/providers/course_provider.dart";
import "lecture_list_screen.dart";
import "widgets/chapter_list.dart";
import "widgets/course_card.dart" show colorForBatch, examCodeForBatch;
import "widgets/subject_list.dart";

class CourseDetailScreen extends StatefulWidget {
  final Batch batch;

  const CourseDetailScreen({super.key, required this.batch});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Subject? _selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CourseProvider>();
      await provider.loadBatchProgress(widget.batch.id);
      await provider.loadSubjects(widget.batch.id);
      if (!mounted) return;
      if (provider.subjects.isNotEmpty) {
        _onSelectSubject(provider.subjects.first);
      }
    });
  }

  void _onSelectSubject(Subject subject) {
    setState(() => _selectedSubject = subject);
    context.read<CourseProvider>().loadChapters(subject.id);
  }

  Future<void> _openChapter(Chapter chapter) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LectureListScreen(chapter: chapter, batchId: widget.batch.id),
      ),
    );
    if (!mounted) return;
    context.read<CourseProvider>().loadBatchProgress(widget.batch.id);
  }

  Widget _buildProgressCard(BuildContext context, Color color, CourseProvider provider) {
    if (provider.isLoadingProgress && provider.batchProgress == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final progress = provider.batchProgress;
    if (progress == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Study Progress", style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                "${progress.progressPercent.round()}%",
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.totalLectures == 0 ? 0 : progress.progressPercent / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${progress.completedChapters}/${progress.totalChapters} chapters • "
            "${progress.completedLectures}/${progress.totalLectures} lectures completed",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          if (progress.continueLearning != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.play_circle_outline, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Continue: ${progress.continueLearning!.lectureTitle}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (progress.lastWatched != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Last watched: ${progress.lastWatched!.lectureTitle}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForBatch(widget.batch.id);
    final examTag = examCodeForBatch(widget.batch.examId);

    return Scaffold(
      appBar: AppBar(title: Text(widget.batch.title)),
      body: SafeArea(
        child: Consumer<CourseProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: color, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              examTag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            if (widget.batch.description.isNotEmpty)
                              Text(
                                widget.batch.description,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildProgressCard(context, color, provider),
                Text("Subjects", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (provider.isLoadingSubjects)
                  const Center(child: CircularProgressIndicator())
                else if (provider.subjectsError != null)
                  Text(provider.subjectsError!, style: TextStyle(color: Colors.grey[600]))
                else if (provider.subjects.isEmpty)
                  Text("No subjects available", style: TextStyle(color: Colors.grey[600]))
                else
                  SubjectList(
                    subjects: provider.subjects,
                    selectedSubject: _selectedSubject,
                    onSelect: _onSelectSubject,
                  ),
                const SizedBox(height: 24),
                if (_selectedSubject != null) ...[
                  Text("Chapters", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (provider.isLoadingChapters)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.chaptersError != null)
                    Text(provider.chaptersError!, style: TextStyle(color: Colors.grey[600]))
                  else
                    ChapterList(
                      chapters: provider.chapters,
                      accentColor: colorForBatch(_selectedSubject!.id),
                      onTapChapter: _openChapter,
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
