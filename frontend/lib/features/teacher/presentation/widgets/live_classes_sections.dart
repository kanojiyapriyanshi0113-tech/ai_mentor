import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../../../core/theme/app_colors.dart";
import "../../../../core/theme/app_spacing.dart";
import "../../../../core/models/teacher_models.dart";
import "../../../../shared/widgets/retry_state.dart";
import "../providers/teacher_provider.dart";

String _formatDateTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, "0");
  final m = dt.minute.toString().padLeft(2, "0");
  return "${dt.day}/${dt.month} $h:$m";
}

bool _isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

class _LiveClassTile extends StatelessWidget {
  final LiveClassModel liveClass;

  const _LiveClassTile({required this.liveClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: const Icon(Icons.videocam_outlined, color: AppColors.primary, size: 18),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  liveClass.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                ),
                Text(
                  _formatDateTime(liveClass.scheduledAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // NOTE: no in-app "join" flow wired here - meetingUrl exists on
          // the model but launching external links needs url_launcher,
          // which isn't a confirmed dependency. Wire this once you confirm it.
          OutlinedButton(
            onPressed: liveClass.meetingUrl.isEmpty ? null : () {},
            child: const Text("Join"),
          ),
        ],
      ),
    );
  }
}

/// Shows only today's scheduled live classes, computed client-side from
/// TeacherProvider.dashboard.upcomingLiveClasses (no new API call).
class TodaysScheduleSection extends StatelessWidget {
  const TodaysScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        if (provider.dashboardStatus == LoadStatus.error) {
          return RetryState(
            message: provider.errorMessage ?? "Couldn't load today's schedule.",
            onRetry: provider.loadDashboard,
          );
        }
        final all = provider.dashboard?.upcomingLiveClasses ?? [];
        final today = all.where((c) => _isToday(c.scheduledAt)).toList();

        if (today.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No live classes scheduled today.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return Column(children: today.map((c) => _LiveClassTile(liveClass: c)).toList());
      },
    );
  }
}

/// Shows all upcoming live classes (today and beyond).
class UpcomingLiveClassesSection extends StatelessWidget {
  const UpcomingLiveClassesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, _) {
        if (provider.dashboardStatus == LoadStatus.error) {
          return RetryState(
            message: provider.errorMessage ?? "Couldn't load upcoming live classes.",
            onRetry: provider.loadDashboard,
          );
        }
        final all = provider.dashboard?.upcomingLiveClasses ?? [];

        if (all.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "No upcoming live classes.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          );
        }

        return Column(children: all.map((c) => _LiveClassTile(liveClass: c)).toList());
      },
    );
  }
}
