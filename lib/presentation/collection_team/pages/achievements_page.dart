import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAchievements(force: true));
  }

  Future<void> _loadAchievements({bool force = false}) async {
    if (_loading) {
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.empId;
    if (userId == null) {
      return;
    }

    setState(() => _loading = true);

    final gamificationProvider = context.read<GamificationTasksProvider>();
    final role = context.read<AuthProvider>().currentUser?.role;

    try {
      if (role != null && role.isNotEmpty) {
        await gamificationProvider.loadAvailableTasks(role);
      }
      if (force) {
        await gamificationProvider.reloadUserTasks(userId);
      } else {
        await gamificationProvider.loadUserTasks(userId);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        foregroundColor: AppColors.grey900,
        elevation: 0,
        title: Text('Achievements', style: AppTypography.titleLg),
      ),
      body: Consumer<GamificationTasksProvider>(
        builder: (context, gamificationProvider, _) {
          if (_loading && gamificationProvider.userTasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (gamificationProvider.errorMessage != null &&
              gamificationProvider.userTasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gamificationProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.red500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _loadAchievements(force: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _loadAchievements(force: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: _buildContent(gamificationProvider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(GamificationTasksProvider gamificationProvider) {
    final completedTasks = gamificationProvider.completedTasks;
    final ongoingTasks = gamificationProvider.ongoingTasks;
    final totalTasks = gamificationProvider.totalTasks;
    final totalCompleted = gamificationProvider.totalCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(badge: totalTasks > 0 ? '$totalCompleted/$totalTasks' : null),
        const SizedBox(height: 16),
        if (completedTasks.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed',
                style: AppTypography.titleSm.copyWith(color: AppColors.grey700),
              ),
              const SizedBox(height: 12),
              ...completedTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCompletedTaskCard(task),
                );
              }),
              const SizedBox(height: 20),
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(color: AppColors.grey300),
              ),
              const SizedBox(height: 20),
            ],
          ),
        if (ongoingTasks.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'In Progress',
                style: AppTypography.titleSm.copyWith(color: AppColors.grey700),
              ),
              const SizedBox(height: 12),
              ...ongoingTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOngoingTaskCard(task),
                );
              }),
            ],
          )
        else if (completedTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card(),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined, color: AppColors.green700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No achievements yet. Complete routes to earn badges.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenSurface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.greenBorder2),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.green700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Great job! You\'ve completed all tasks.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.green700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader({String? badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.stars_outlined, color: AppColors.grey900, size: 24),
            const SizedBox(width: 8),
            Text('Achievements', style: AppTypography.titleLg),
          ],
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: ShapeDecoration(
              color: AppColors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              badge,
              style: AppTypography.captionSm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.yellowDark,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletedTaskCard(UserTaskProgress task) {
    final progressPercent = task.progressPercentage;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.green700,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskTitle,
                        style: AppTypography.titleMd,
                      ),
                    ),
                    if (task.isNew) _buildNewBadge(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _shortTaskDescription(task.taskDescription),
                  style: AppTypography.caption,
                ),
                if (_buildTaskDuration(task) != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildTaskDuration(task)!,
                    style: AppTypography.captionSm.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  task.pointsStatusLabel,
                  style: AppTypography.captionSm.copyWith(
                    color: task.isCompleted
                        ? AppColors.yellow400
                        : AppColors.green700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    backgroundColor: AppColors.grey200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.green700,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.currentProgress.toStringAsFixed(0)}/${task.targetProgress.toStringAsFixed(0)} complete',
                  style: AppTypography.overline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.check_circle,
            color: AppColors.green700,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingTaskCard(UserTaskProgress task) {
    final progressPercent = task.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Icon(
            task.currentProgress > 0
                ? Icons.trending_up_rounded
                : Icons.lock_outline_rounded,
            color: task.currentProgress > 0
                ? AppColors.green700
                : AppColors.grey400,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskTitle,
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    if (task.isNew) _buildNewBadge(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _shortTaskDescription(task.taskDescription),
                  style: AppTypography.caption,
                ),
                if (_buildTaskDuration(task) != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildTaskDuration(task)!,
                    style: AppTypography.captionSm.copyWith(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  task.pointsStatusLabel,
                  style: AppTypography.captionSm.copyWith(
                    color: task.isCompleted
                        ? AppColors.yellow400
                        : AppColors.green700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent / 100,
                    backgroundColor: AppColors.grey200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.green700,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.currentProgress.toStringAsFixed(0)}/${task.targetProgress.toStringAsFixed(0)} complete',
                  style: AppTypography.overline.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortTaskDescription(String description) {
    final normalized = description.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return 'Complete to earn points.';
    }
    if (normalized.length <= 34) {
      return normalized;
    }
    return '${normalized.substring(0, 31).trimRight()}...';
  }

  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blue100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'NEW',
        style: AppTypography.overline.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.green700,
        ),
      ),
    );
  }

  String? _buildTaskDuration(UserTaskProgress task) {
    final label = task.activePeriodLabel?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    if ((task.startAt == null || task.startAt!.isEmpty) &&
        (task.endAt == null || task.endAt!.isEmpty)) {
      return null;
    }
    final start = task.startAt != null ? DateTime.tryParse(task.startAt!) : null;
    final end = task.endAt != null ? DateTime.tryParse(task.endAt!) : null;
    final startLabel = start != null ? _formatTaskDate(start) : null;
    final endLabel = end != null ? _formatTaskDate(end) : null;
    if (startLabel != null && endLabel != null) {
      return '$startLabel - $endLabel';
    }
    if (endLabel != null) {
      return 'Valid until $endLabel';
    }
    if (startLabel != null) {
      return 'Started $startLabel';
    }
    return null;
  }

  String _formatTaskDate(DateTime value) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[value.month - 1]} ${value.day}';
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
