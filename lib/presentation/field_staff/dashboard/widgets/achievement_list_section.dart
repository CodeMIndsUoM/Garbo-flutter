import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';
import 'package:garbo_swms/presentation/collection_team/pages/achievements_page.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:provider/provider.dart';

class AchievementListSection extends StatelessWidget {
  const AchievementListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationTasksProvider>(
      builder: (context, gamificationProvider, _) {
        final completedTasks = [...gamificationProvider.completedTasks]
          ..sort(
            (left, right) =>
                _completionDate(right).compareTo(_completionDate(left)),
          );
        final recent = completedTasks.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.grey900,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('Recent Achievements', style: AppTypography.titleLg),
              ],
            ),
            const SizedBox(height: 12),
            if (gamificationProvider.isLoading && recent.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recent.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(),
                child: Text(
                  'No completed achievements yet. Progress updates will appear here in realtime.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              ...recent.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAchievementItem(
                    context: context,
                    title: task.taskTitle,
                    subtitle: _relativeTime(_completionDate(task)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementItem({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AchievementsPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.orange500, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSm.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.green700,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _completionDate(UserTaskProgress task) {
    if (task.completedAt == null || task.completedAt!.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(task.completedAt!) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _relativeTime(DateTime completedAt) {
    if (completedAt.millisecondsSinceEpoch == 0) {
      return 'Recently earned';
    }

    final diff = DateTime.now().difference(completedAt);
    if (diff.inMinutes < 1) {
      return 'Earned just now';
    }
    if (diff.inHours < 1) {
      return 'Earned ${diff.inMinutes}m ago';
    }
    if (diff.inDays < 1) {
      return 'Earned ${diff.inHours}h ago';
    }
    return 'Earned ${diff.inDays}d ago';
  }
}
