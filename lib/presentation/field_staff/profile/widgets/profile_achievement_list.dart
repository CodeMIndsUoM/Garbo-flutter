import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

class ProfileAchievementList extends StatefulWidget {
  const ProfileAchievementList({super.key});

  @override
  State<ProfileAchievementList> createState() => _ProfileAchievementListState();
}

class _ProfileAchievementListState extends State<ProfileAchievementList> {
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _taskProgressSubscription;
  Timer? _refreshDebounce;
  int? _activeUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.empId;
      if (userId != null) {
        _activeUserId = userId;
        context.read<GamificationTasksProvider>().loadUserTasks(userId);
      }
      _attachWebSocketRefresh(context.read<WebSocketProvider>());
    });
  }

  void _attachWebSocketRefresh(WebSocketProvider webSocketProvider) {
    _taskProgressSubscription?.cancel();
    _taskProgressSubscription = webSocketProvider.messageStream.listen((message) {
      if (message.type != 'TASK_PROGRESS_UPDATE' || _activeUserId == null) {
        return;
      }

      final messageUserId = message.userId;
      if (messageUserId != null && messageUserId != _activeUserId) {
        return;
      }

      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!mounted || _activeUserId == null) {
          return;
        }
        context.read<GamificationTasksProvider>().reloadUserTasks(_activeUserId!);
      });
    });
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    _taskProgressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Consumer<GamificationTasksProvider>(
      builder: (context, provider, _) {
        final completedTasks = provider.completedTasks;
        final completedCount = provider.totalCompleted;
        final totalCount = provider.totalTasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_outlined, color: AppColors.grey900, size: 24),
                    const SizedBox(width: 8),
                    Text('Achievements', style: AppTypography.titleLg),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: ShapeDecoration(
                    color: AppColors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '$completedCount/$totalCount',
                    style: AppTypography.captionSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.yellowDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (completedTasks.isEmpty)
              Text(
                'Complete tasks to earn achievements',
                style: AppTypography.caption.copyWith(color: AppColors.grey600),
              )
            else
              ...completedTasks.take(5).map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAchievementCard(
                    title: task.taskTitle,
                    description: task.taskDescription,
                    earnedText: task.isCompleted && task.pointsEarned > 0
                        ? '${task.pointsEarned.toStringAsFixed(0)} pts earned'
                        : 'Reward: ${task.availablePoints.toStringAsFixed(0)} pts',
                    icon: Icons.emoji_events_outlined,
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String description,
    required String earnedText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.green700, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTypography.caption.copyWith(color: AppColors.grey600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.green700, size: 14),
                    const SizedBox(width: 4),
                    Text(earnedText, style: AppTypography.captionSm.copyWith(color: AppColors.green700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
