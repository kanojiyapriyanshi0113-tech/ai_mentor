import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/models/planner_model.dart";
import "../../core/providers/planner_provider.dart";
import "../../core/theme/app_spacing.dart";
import "widgets/plan_history_card.dart";

/// List of previously saved plans, backed by [PlannerProvider].
///
/// Tapping a card opens actions to mark it complete or delete it.
class PlanHistoryScreen extends StatefulWidget {
  const PlanHistoryScreen({super.key});

  @override
  State<PlanHistoryScreen> createState() => _PlanHistoryScreenState();
}

class _PlanHistoryScreenState extends State<PlanHistoryScreen> {
  bool _hasLoadedOnce = false;

  Future<void> _openActions(PlannerPlan plan) async {
    final provider = context.read<PlannerProvider>();

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(plan.goal, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(plan.isCompleted ? "Completed" : "Pending"),
              ),
              if (!plan.isCompleted)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text("Mark as complete"),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final success = await provider.completePlan(plan.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? "Plan marked complete" : (provider.error ?? "Failed to update plan")),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Delete", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final success = await provider.deletePlan(plan.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Plan deleted" : (provider.error ?? "Failed to delete plan")),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<PlannerProvider>().loadPlans();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan History"),
      ),
      body: SafeArea(
        child: Consumer<PlannerProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => provider.loadPlans(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            final history = List<PlannerPlan>.of(provider.plans)
              ..sort((a, b) => b.date.compareTo(a.date));

            if (history.isEmpty) {
              return const _EmptyState();
            }

            return RefreshIndicator(
              onRefresh: provider.loadPlans,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final plan = history[index];
                  return PlanHistoryCard(
                    plan: plan,
                    onTap: () => _openActions(plan),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          "No saved plans yet",
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
