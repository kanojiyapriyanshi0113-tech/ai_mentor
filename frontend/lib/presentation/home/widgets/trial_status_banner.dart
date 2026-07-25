import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/user_provider.dart';

class TrialStatusBanner extends StatelessWidget {
  const TrialStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    if (user.premium) {
      return _buildBanner(
        context,
        icon: Icons.workspace_premium,
        text: 'Premium Member',
        color: Colors.amber[700]!,
      );
    }

    final daysLeft = user.trialEndDate.difference(DateTime.now()).inDays;
    final trialActive = daysLeft >= 0;

    return _buildBanner(
      context,
      icon: trialActive ? Icons.hourglass_bottom : Icons.lock_clock,
      text: trialActive
          ? '$daysLeft day${daysLeft == 1 ? '' : 's'} left in your free trial'
          : 'Your trial has ended — upgrade to continue',
      color: trialActive ? Colors.blue[700]! : Colors.red[700]!,
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
