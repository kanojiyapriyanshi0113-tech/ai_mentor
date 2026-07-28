import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../providers/teacher_provider.dart";

enum _SearchCategory { pdfs, mockTests }

/// Teacher Search screen.
///
/// There is no /search endpoint on the backend, so this filters
/// client-side over data the app already loads: PDFs and Mock Tests
/// (both have real GET /teacher/... list endpoints, wired earlier).
///
/// NOTE: "Students", "Lectures", and "Subjects" from the original spec
/// are NOT included - there is no list endpoint for a teacher's own
/// students, lectures, or subjects on the backend (only create/update/
/// delete for the latter two). Add list endpoints for those to make
/// them searchable too.
class TeacherSearchScreen extends StatefulWidget {
  const TeacherSearchScreen({super.key});

  @override
  State<TeacherSearchScreen> createState() => _TeacherSearchScreenState();
}

class _TeacherSearchScreenState extends State<TeacherSearchScreen> {
  final _controller = TextEditingController();
  String _query = "";
  _SearchCategory _category = _SearchCategory.pdfs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TeacherProvider>();
      if (provider.pdfsStatus == LoadStatus.idle) provider.loadPdfs();
      if (provider.mockTestsStatus == LoadStatus.idle) provider.loadMockTests();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();
    final q = _query.trim().toLowerCase();

    final pdfResults = q.isEmpty
        ? <String>[]
        : provider.pdfs.where((p) => p.title.toLowerCase().contains(q)).map((p) => p.title).toList();

    final mockResults = q.isEmpty
        ? <String>[]
        : provider.mockTests
            .where((m) => m.title.toLowerCase().contains(q))
            .map((m) => "${m.title}  \u00b7  ${m.totalQuestions} questions")
            .toList();

    final results = _category == _SearchCategory.pdfs ? pdfResults : mockResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Search")),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search PDFs, mock tests...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _CategoryChip(
                  label: "PDFs",
                  selected: _category == _SearchCategory.pdfs,
                  onTap: () => setState(() => _category = _SearchCategory.pdfs),
                ),
                _CategoryChip(
                  label: "Mock Tests",
                  selected: _category == _SearchCategory.mockTests,
                  onTap: () => setState(() => _category = _SearchCategory.mockTests),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            Expanded(
              child: q.isEmpty
                  ? const Center(
                      child: Text("Start typing to search.", style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : results.isEmpty
                      ? const Center(
                          child: Text("No matches found.", style: TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) => ListTile(
                            title: Text(results[i], style: const TextStyle(fontSize: 13)),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontSize: 12),
    );
  }
}
