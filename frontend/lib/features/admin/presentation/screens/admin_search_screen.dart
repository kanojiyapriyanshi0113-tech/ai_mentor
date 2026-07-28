import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../providers/admin_provider.dart";

enum _SearchCategory { teachers, students, payments, subscriptions }

/// Admin Search screen.
///
/// There is no /search endpoint anywhere on the backend, so this filters
/// client-side over data the app already loads through real endpoints:
/// Teachers, Students, Payments, and the Subscription plan catalog.
///
/// NOTE: "Courses" and "Reports" from the original spec are NOT
/// included as searchable categories - there is no course-list model
/// (only aggregate counts) and Reports aren't a list of items to
/// search through. Add list endpoints for those to make them
/// searchable too.
class AdminSearchScreen extends StatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  State<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends State<AdminSearchScreen> {
  final _controller = TextEditingController();
  String _query = "";
  _SearchCategory _category = _SearchCategory.teachers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      if (provider.teachersStatus == LoadStatus.idle) provider.loadTeachers();
      if (provider.studentsStatus == LoadStatus.idle) provider.loadStudents();
      if (provider.paymentsStatus == LoadStatus.idle) provider.loadPayments();
      if (provider.planCatalogStatus == LoadStatus.idle) provider.loadPlanCatalog();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final q = _query.trim().toLowerCase();

    final teacherResults = q.isEmpty
        ? <String>[]
        : provider.teachers
            .where((t) => t.name.toLowerCase().contains(q) || t.email.toLowerCase().contains(q))
            .map((t) => "${t.name}  \u00b7  ${t.email}")
            .toList();

    final studentResults = q.isEmpty
        ? <String>[]
        : provider.students
            .where((s) => s.name.toLowerCase().contains(q) || s.email.toLowerCase().contains(q))
            .map((s) => "${s.name}  \u00b7  ${s.email}")
            .toList();

    final paymentResults = q.isEmpty
        ? <String>[]
        : provider.payments
            .where((p) => p.transactionRef.toLowerCase().contains(q) || p.status.toLowerCase().contains(q))
            .map((p) => "\u20b9${(p.amountPaise / 100).toStringAsFixed(0)}  \u00b7  ${p.transactionRef}  \u00b7  ${p.status}")
            .toList();

    final planResults = q.isEmpty
        ? <String>[]
        : provider.planCatalog
            .where((p) => p.name.toLowerCase().contains(q) || p.code.toLowerCase().contains(q))
            .map((p) => "${p.name}  \u00b7  ${p.code}")
            .toList();

    final Map<_SearchCategory, List<String>> resultsByCategory = {
      _SearchCategory.teachers: teacherResults,
      _SearchCategory.students: studentResults,
      _SearchCategory.payments: paymentResults,
      _SearchCategory.subscriptions: planResults,
    };

    final results = resultsByCategory[_category]!;

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
                hintText: "Search teachers, students, payments, plans...",
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
                  label: "Teachers",
                  selected: _category == _SearchCategory.teachers,
                  onTap: () => setState(() => _category = _SearchCategory.teachers),
                ),
                _CategoryChip(
                  label: "Students",
                  selected: _category == _SearchCategory.students,
                  onTap: () => setState(() => _category = _SearchCategory.students),
                ),
                _CategoryChip(
                  label: "Payments",
                  selected: _category == _SearchCategory.payments,
                  onTap: () => setState(() => _category = _SearchCategory.payments),
                ),
                _CategoryChip(
                  label: "Subscriptions",
                  selected: _category == _SearchCategory.subscriptions,
                  onTap: () => setState(() => _category = _SearchCategory.subscriptions),
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
