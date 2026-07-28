import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/providers/planner_provider.dart";
import "../../core/network/ai_chat_api_service.dart";
import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";
import "calendar_screen.dart";
import "plan_history_screen.dart";

const List<String> _kMonthShortNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

/// Home screen for the AI Planner feature.
///
/// Date selection, a goal text field, a Save button, and a link to plan
/// history. Save is wired through [PlannerProvider] -> [PlannerApiService]
/// (via [ApiPlannerService]), with loading, success, and error states.
class PlannerHomeScreen extends StatefulWidget {
  const PlannerHomeScreen({super.key});

  @override
  State<PlannerHomeScreen> createState() => _PlannerHomeScreenState();
}

class _PlannerHomeScreenState extends State<PlannerHomeScreen> {
  final TextEditingController _goalController = TextEditingController();
  final AIChatApiService _aiChatService = AIChatApiService();
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final result = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (context) => CalendarScreen(initialDate: _selectedDate),
      ),
    );

    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PlanHistoryScreen()),
    );
  }

  Future<void> _askAI() async {
    final questionController = TextEditingController();
    bool isAsking = false;
    String? askError;
    String? suggestion;

    Future<void> fetchSuggestion(void Function(void Function()) setSheetState) async {
      final question = questionController.text.trim();
      if (question.isEmpty) {
        setSheetState(() => askError = "Please type your question first");
        return;
      }
      setSheetState(() {
        isAsking = true;
        askError = null;
        suggestion = null;
      });
      try {
        final result = await _aiChatService.sendMessage(
          "You are a study planning assistant. Based on this student request, reply with ONLY "
          "one short, specific, actionable study goal for today - a single sentence, no more than "
          "25 words. Do not add explanations, greetings, questions, or follow-up remarks, and do not "
          "wrap it in quotes. Student request: $question",
        );
        setSheetState(() {
          isAsking = false;
          suggestion = result.reply.trim();
        });
      } catch (e) {
        setSheetState(() {
          isAsking = false;
          askError = "Couldn't reach AI. Please try again.";
        });
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Ask AI for a plan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    "Tell it what you're preparing for, and it'll suggest a goal.",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: questionController,
                    maxLines: 3,
                    autofocus: suggestion == null,
                    decoration: const InputDecoration(
                      hintText: "e.g. JEE exam in 2 weeks, what should I study today?",
                    ),
                  ),
                  if (askError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(askError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  if (suggestion != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 180),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          suggestion!,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (suggestion == null)
                    ElevatedButton.icon(
                      onPressed: isAsking ? null : () => fetchSuggestion(setSheetState),
                      icon: isAsking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(isAsking ? "Thinking..." : "Get Suggestion"),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isAsking ? null : () => fetchSuggestion(setSheetState),
                            child: isAsking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text("Try another"),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isAsking
                                ? null
                                : () {
                                    _goalController.text = suggestion!;
                                    Navigator.of(sheetContext).pop();
                                  },
                            child: const Text("Use this"),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _savePlan() async {
    if (_isSaving) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date first")),
      );
      return;
    }

    if (_goalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a goal")),
      );
      return;
    }

    final date = _selectedDate!;
    final goal = _goalController.text.trim();
    final formattedDate = "${date.day} ${_kMonthShortNames[date.month - 1]} ${date.year}";

    setState(() => _isSaving = true);

    final provider = context.read<PlannerProvider>();
    final success = await provider.createPlan(date: date, goal: goal);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plan saved for $formattedDate")),
      );
      _goalController.clear();
      setState(() => _selectedDate = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? "Failed to save plan. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Planner"),
        actions: [
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history_rounded),
            tooltip: "History",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Plan your day",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                "Pick a date and set a goal for it.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Card(
                child: InkWell(
                  onTap: _openCalendar,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _selectedDate == null
                                    ? "Tap to select a date"
                                    : "${_selectedDate!.day} ${_kMonthShortNames[_selectedDate!.month - 1]} ${_selectedDate!.year}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Goal",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _askAI,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text("Ask AI"),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _goalController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "What do you want to achieve on this day?",
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePlan,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isSaving ? "Saving..." : "Save"),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _openHistory,
                icon: const Icon(Icons.history_rounded),
                label: const Text("View History"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
