import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/exam_api_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/router/app_routes.dart';

const Map<String, IconData> _examIcons = {
  // Government Jobs
  'UPSC': Icons.account_balance,
  'SSC': Icons.description,
  'BANKING': Icons.account_balance_wallet,
  'RAILWAY': Icons.train,
  'STATE_PSC': Icons.gavel,
  // Higher Education
  'CAT': Icons.trending_up,
  'GATE': Icons.engineering,
  'UGC_NET': Icons.menu_book,
  'CUET_PG': Icons.school,
  // Teaching
  'CTET': Icons.cast_for_education,
  'REET': Icons.cast_for_education,
  'KVS': Icons.cast_for_education,
  // Defence
  'CDS': Icons.shield,
  'CAPF': Icons.shield_outlined,
  'AFCAT': Icons.flight,
  // Law
  'JUDICIARY': Icons.balance,
  'CLAT_PG': Icons.balance,
};

const List<String> _categoryOrder = [
  'Government Jobs',
  'Higher Education',
  'Teaching',
  'Defence',
  'Law',
];

class ExamSelectionScreen extends StatefulWidget {
  const ExamSelectionScreen({super.key});

  @override
  State<ExamSelectionScreen> createState() => _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends State<ExamSelectionScreen> {
  final _examService = ExamApiService();
  List<ExamOption> _exams = [];
  int? _selectedExamId;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final exams = await _examService.listExams();
      setState(() => _exams = exams);
    } catch (e) {
      setState(() => _loadError = 'Failed to load exams. Pull to retry.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedExamId == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final selected = await _examService.selectExam(_selectedExamId!);
      if (!mounted) return;
      context.read<UserProvider>().updateSelectedExam(selected.name, selected.id);
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to select exam. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Map<String, List<ExamOption>> _groupByCategory(List<ExamOption> exams) {
    final grouped = <String, List<ExamOption>>{};
    for (final exam in exams) {
      grouped.putIfAbsent(exam.category, () => []).add(exam);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Exam')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_loadError!),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _loadExams, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _buildExamList(context),
      ),
    );
  }

  Widget _buildExamList(BuildContext context) {
    final grouped = _groupByCategory(_exams);
    final categories = [
      ..._categoryOrder.where(grouped.containsKey),
      ...grouped.keys.where((c) => !_categoryOrder.contains(c)),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which exam are you preparing for?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                for (final category in categories) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 10),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[700],
                          ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: grouped[category]!.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) {
                      final exam = grouped[category]![index];
                      final isSelected = _selectedExamId == exam.id;
                      final icon = _examIcons[exam.code] ?? Icons.school;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedExamId = exam.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 36,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[700],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exam.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedExamId == null || _isSubmitting ? null : _confirmSelection,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
