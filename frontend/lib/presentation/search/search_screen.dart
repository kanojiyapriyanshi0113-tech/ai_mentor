import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/providers/course_provider.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";
import "../../features/admin/presentation/providers/admin_provider.dart";
// `LoadStatus` is declared identically in both provider files, so hide
// the teacher module's copy here to avoid an ambiguous-import error;
// this screen only reads `LoadStatus` off the admin provider.
import "../../features/teacher/presentation/providers/teacher_provider.dart" hide LoadStatus;

enum SearchRole { teacher, admin }

class _SearchResult {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SearchResult({required this.title, required this.subtitle, required this.icon});
}

/// Shared Search Screen. Filters whatever lists are already loaded in
/// [TeacherProvider] / [AdminProvider] / [CourseProvider] client-side -
/// there's no dedicated /search endpoint yet, so categories without a
/// loaded list show an honest "not available yet" state instead of
/// silently returning nothing.
class SearchScreen extends StatefulWidget {
  final SearchRole role;

  const SearchScreen({super.key, required this.role});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = "";
  late String _category;

  List<String> get _categories => widget.role == SearchRole.teacher
      ? const ["Students", "Lectures", "PDFs", "Mock Tests"]
      : const ["Teachers", "Students", "Courses", "Payments", "Reports"];

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.role == SearchRole.admin) {
        final admin = context.read<AdminProvider>();
        if (admin.teachersStatus == LoadStatus.idle) admin.loadTeachers();
        if (admin.studentsStatus == LoadStatus.idle) admin.loadStudents();
        if (admin.paymentsStatus == LoadStatus.idle) admin.loadPayments();
        context.read<CourseProvider>().loadBatches();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SearchResult>? _resultsFor(String category) {
    final q = _query.trim().toLowerCase();
    bool matches(String s) => q.isEmpty || s.toLowerCase().contains(q);

    if (widget.role == SearchRole.teacher) {
      final teacher = context.watch<TeacherProvider>();
      switch (category) {
        case "Lectures":
          return teacher.lectures
              .where((l) => matches(l.title))
              .map((l) => _SearchResult(title: l.title, subtitle: "Lecture \u00b7 ${l.durationMinutes} min", icon: Icons.play_circle_outline))
              .toList();
        case "PDFs":
          return teacher.pdfs
              .where((p) => matches(p.title))
              .map((p) => _SearchResult(title: p.title, subtitle: "PDF", icon: Icons.picture_as_pdf_outlined))
              .toList();
        case "Mock Tests":
          return teacher.mockTests
              .where((m) => matches(m.title))
              .map((m) => _SearchResult(title: m.title, subtitle: "Mock Test \u00b7 ${m.totalQuestions} questions", icon: Icons.fact_check_outlined))
              .toList();
        case "Students":
        default:
          return null; // no student directory endpoint yet
      }
    } else {
      final admin = context.watch<AdminProvider>();
      final course = context.watch<CourseProvider>();
      switch (category) {
        case "Teachers":
          return admin.teachers
              .where((t) => matches(t.name) || matches(t.email))
              .map((t) => _SearchResult(title: t.name, subtitle: t.email, icon: Icons.school_outlined))
              .toList();
        case "Students":
          return admin.students
              .where((s) => matches(s.name) || matches(s.email))
              .map((s) => _SearchResult(title: s.name, subtitle: s.email, icon: Icons.groups_outlined))
              .toList();
        case "Courses":
          return course.batches
              .where((b) => matches(b.title))
              .map((b) => _SearchResult(title: b.title, subtitle: "Course", icon: Icons.menu_book_outlined))
              .toList();
        case "Payments":
          return admin.payments
              .where((p) => matches(p.transactionRef) || matches(p.status))
              .map((p) => _SearchResult(
                    title: p.transactionRef,
                    subtitle: "\u20b9${(p.amountPaise / 100).toStringAsFixed(0)} \u00b7 ${p.status}",
                    icon: Icons.payments_outlined,
                  ))
              .toList();
        case "Reports":
        default:
          return null; // no report-search endpoint yet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _resultsFor(_category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: "Search ${widget.role == SearchRole.teacher ? "students, lectures, PDFs..." : "teachers, students, courses..."}",
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _controller.clear();
                _query = "";
              }),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: _categories
                    .map(
                      (c) => Padding(
                        padding: EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: _category == c,
                          onSelected: (_) => setState(() => _category = c),
                          selectedColor: AppColors.primaryLight,
                          labelStyle: TextStyle(
                            color: _category == c ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          side: BorderSide(color: _category == c ? AppColors.primary : AppColors.border),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Expanded(
              child: results == null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          "$_category search isn't connected to a backend endpoint yet.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : results.isEmpty
                      ? Center(
                          child: Text(
                            _query.isEmpty ? "Start typing to search $_category." : "No results for \"$_query\".",
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final r = results[index];
                            return Container(
                              padding: EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppSpacing.lg),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(r.icon, color: AppColors.primary, size: 20),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                        SizedBox(height: AppSpacing.xs),
                                        Text(r.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}