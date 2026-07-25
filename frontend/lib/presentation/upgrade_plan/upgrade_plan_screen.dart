import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/models/subscription_model.dart";
import "../../core/providers/subscription_provider.dart";

class UpgradePlanScreen extends StatefulWidget {
  const UpgradePlanScreen({super.key});

  @override
  State<UpgradePlanScreen> createState() => _UpgradePlanScreenState();
}

class _UpgradePlanScreenState extends State<UpgradePlanScreen> {
  String? _upgradingPlanCode;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionProvider>().loadPlans();
  }

  Future<void> _handleUpgrade(SubscriptionPlan plan) async {
    setState(() => _upgradingPlanCode = plan.code);

    final success = await context.read<SubscriptionProvider>().upgradePlan(plan.code);

    if (!mounted) return;
    setState(() => _upgradingPlanCode = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Upgraded to ${plan.name}" : "Failed to upgrade. Please try again.",
        ),
      ),
    );

    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade Plan")),
      body: provider.isLoadingPlans
          ? const Center(child: CircularProgressIndicator())
          : provider.plansError != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.plansError!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<SubscriptionProvider>().loadPlans(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final plan = provider.plans[index];
                    final isCurrentPlan = provider.summary?.currentPlan == plan.name;

                    return _PlanCard(
                      plan: plan,
                      isCurrentPlan: isCurrentPlan,
                      isUpgrading: _upgradingPlanCode == plan.code,
                      onUpgrade: () => _handleUpgrade(plan),
                    );
                  },
                ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isUpgrading;
  final VoidCallback onUpgrade;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.isUpgrading,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final config = getPlanFeatureConfig(plan.code);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentPlan ? Theme.of(context).primaryColor : Colors.grey[200]!,
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                plan.pricePaise == 0
                    ? plan.priceLabel
                    : "${plan.priceLabel}/${plan.durationDays >= 300 ? "year" : "month"}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...config.included.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ),
          ...config.locked.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isCurrentPlan
                ? const OutlinedButton(
                    onPressed: null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text("Current Plan"),
                    ),
                  )
                : ElevatedButton(
                    onPressed: isUpgrading ? null : onUpgrade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: isUpgrading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Upgrade"),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}