import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/collection_team/pages/leaderboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/bottom_navigation.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';

class CollectionTeamDashboard extends StatefulWidget {
  const CollectionTeamDashboard({super.key});

  @override
  State<CollectionTeamDashboard> createState() => CollectionTeamDashboardState();
}

class CollectionTeamDashboardState extends State<CollectionTeamDashboard> {
  bool _didPrimeGamification = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrimeGamification) {
      return;
    }

    _didPrimeGamification = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final gamificationProvider = context.read<GamificationTasksProvider>();
      final user = authProvider.currentUser;

      if (user != null) {
        gamificationProvider.loadUserTasks(user.empId);
        gamificationProvider.loadAvailableTasks(user.role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final routeProvider = context.watch<RouteProvider>();
    final gamificationProvider = context.watch<GamificationTasksProvider>();

    final currentUserId = authProvider.currentUser?.empId;
    final userEntry = currentUserId == null
        ? null
        : leaderboardProvider.getUserRank(currentUserId);

    final points = userEntry?.rewardPoints ??
        gamificationProvider.completedTasks.fold<double>(
          0.0,
          (sum, task) => sum + task.pointsEarned,
        );
    final level = _resolveLevel(points);
    final levelProgress = _resolveLevelProgress(points);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const HeaderReduced(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLevelCard(
                    userEntry: userEntry,
                    level: level,
                    points: points,
                    levelProgress: levelProgress,
                  ),
                  const SizedBox(height: 24),
                  buildTodaysPerformance(
                    context: context,
                    authProvider: authProvider,
                    routeProvider: routeProvider,
                    gamificationProvider: gamificationProvider,
                  ),
                  const SizedBox(height: 24),
                  buildTodaysRoutes(routeProvider),
                  const SizedBox(height: 24),
                  buildRecentAchievements(gamificationProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 0),
    );
  }

  Widget buildLevelCard({
    required LeaderboardEntryDto? userEntry,
    required int level,
    required double points,
    required double levelProgress,
  }) {
    final rankText = userEntry?.rank != null ? '#${userEntry!.rank}' : '--';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LeaderboardPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blue50, AppColors.indigo50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.blue200, width: 1.27),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.blue500,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level $level',
                            style: const TextStyle(
                              color: AppColors.grey900,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Current Rank $rankText',
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${points.toStringAsFixed(0)} pts',
                        style: const TextStyle(
                          color: AppColors.blue600,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_pointsToNextLevel(points).toStringAsFixed(0)} to Level ${level + 1}',
                        style: const TextStyle(
                          color: AppColors.grey500,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.blue500,
                  ),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Level rule: every 250 points increases 1 level.',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTodaysPerformance({
    required BuildContext context,
    required AuthProvider authProvider,
    required RouteProvider routeProvider,
    required GamificationTasksProvider gamificationProvider,
  }) {
    final now = DateTime.now();

    String dateKey(DateTime value) {
      final year = value.year.toString().padLeft(4, '0');
      final month = value.month.toString().padLeft(2, '0');
      final day = value.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }

    String? extractDateKey(String? rawDate) {
      if (rawDate == null || rawDate.isEmpty) {
        return null;
      }

      // Prefer the raw yyyy-MM-dd prefix from backend timestamp text.
      if (rawDate.length >= 10) {
        return rawDate.substring(0, 10);
      }

      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) {
        return null;
      }
      return dateKey(parsed);
    }

    bool isSameDay(DateTime value) {
      return value.year == now.year &&
          value.month == now.month &&
          value.day == now.day;
    }

    final sessionsToday = routeProvider.routeHistory
        .where((session) => isSameDay(session.generatedAt))
        .toList(growable: false);

    final assignedBins = sessionsToday.fold<int>(
      0,
      (sum, session) => sum + session.totalStops,
    );
    final collectedBins = sessionsToday.fold<int>(
      0,
      (sum, session) => sum + routeProvider.getCollectedCount(session.sessionId),
    );
    final missedBins = sessionsToday.fold<int>(
      0,
      (sum, session) => sum + routeProvider.getSkippedCount(session.sessionId),
    );

    final efficiency = assignedBins == 0
        ? 0.0
        : ((collectedBins / assignedBins) * 100).clamp(0.0, 100.0);

    final routesDone = sessionsToday
        .where((route) => routeProvider.isRouteCompleted(route.sessionId))
        .length;

    final todayKey = dateKey(now);
    final completedToday = gamificationProvider.completedTasks
        .where((task) => extractDateKey(task.completedAt) == todayKey)
        .toList(growable: false);

    final livePoints = completedToday.fold<double>(
      0.0,
      (sum, task) => sum + task.pointsEarned,
    );

    final lastTaskDelta = completedToday.isEmpty
        ? completedToday
            .map((task) => task.pointsEarned)
            .reduce((a, b) => math.max(a, b))
        : 0.0;

    final todayLabel = _formatDateShort(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Performance • $todayLabel",
              style: const TextStyle(
                color: AppColors.grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        if (sessionsToday.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'No routes started today yet. Metrics will update in realtime as you work.',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.62,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            buildPerformanceCard(
              icon: Icons.delete_outline_rounded,
              value: '$collectedBins',
              label: 'Bins Collected',
              subtext: '$assignedBins assigned today',
              iconBg: AppColors.emeraldLight,
              iconColor: AppColors.emerald600,
              subtextColor: AppColors.emerald600,
            ),
            buildPerformanceCard(
              icon: Icons.route_rounded,
              value: '$routesDone',
              label: 'Routes Done',
              subtext: '${sessionsToday.length} total routes today',
              iconBg: AppColors.blue100,
              iconColor: AppColors.blue600,
              subtextColor: AppColors.blue600,
            ),
            buildPerformanceCard(
              icon: Icons.trending_up_rounded,
              value: '${efficiency.toStringAsFixed(0)}%',
              label: 'Efficiency',
              subtext: '$missedBins missed included',
              iconBg: AppColors.purple50,
              iconColor: AppColors.purple600,
              subtextColor: AppColors.purple600,
            ),
            buildPerformanceCard(
              icon: Icons.bolt_rounded,
              value: livePoints.toStringAsFixed(0),
              label: 'Live Points',
              subtext: completedToday.isEmpty
                  ? '0 task points today'
                  : '+${lastTaskDelta.toStringAsFixed(0)} last task done',
              iconBg: AppColors.orange50,
              iconColor: AppColors.orange500,
              subtextColor: AppColors.orange500,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPerformanceCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtext,
    required Color iconBg,
    required Color iconColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100, width: 1.27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtextColor,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(DateTime dateTime) {
    const months = [
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
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  Widget buildTodaysRoutes(RouteProvider routeProvider) {
    final sessions = routeProvider.routeHistory.reversed.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.route_rounded, size: 20, color: AppColors.grey900),
            SizedBox(width: 4),
            Text(
              "Today's Routes",
              style: TextStyle(
                color: AppColors.grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: const Text(
              'No routes yet. Optimize routes to receive realtime updates.',
              style: TextStyle(
                color: AppColors.grey700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          ...sessions.map((session) {
            final collected = routeProvider.getCollectedCount(session.sessionId);
            final skipped = routeProvider.getSkippedCount(session.sessionId);
            final pending = math.max(session.totalStops - (collected + skipped), 0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: buildRouteCard(
                priority: pending == 0 ? 'COMPLETED' : 'IN PROGRESS',
                priorityColor: pending == 0 ? AppColors.green700 : AppColors.red500,
                priorityBg: pending == 0 ? AppColors.emeraldLight : AppColors.red100,
                title: session.title,
                details:
                    '${session.totalStops} bins • ${session.estimatedMinutes} mins • $collected collected',
                gradientColors: pending == 0
                    ? const [AppColors.blue50, AppColors.indigo50]
                    : const [AppColors.red50, AppColors.orange50],
              ),
            );
          }),
      ],
    );
  }

  Widget buildRouteCard({
    required String priority,
    required Color priorityColor,
    required Color priorityBg,
    required String title,
    required String details,
    List<Color>? gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              )
            : null,
        color: gradientColors == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradientColors != null ? priorityBg : AppColors.grey200,
          width: 1.27,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CollectionTeamRoutes()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Open Routes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecentAchievements(GamificationTasksProvider gamificationProvider) {
    final completedTasks = [...gamificationProvider.completedTasks]
      ..sort((left, right) => _completionDate(right).compareTo(_completionDate(left)));

    final recent = completedTasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.emoji_events_rounded,
              size: 20,
              color: AppColors.grey900,
            ),
            SizedBox(width: 4),
            Text(
              'Recent Achievements',
              style: TextStyle(
                color: AppColors.grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: const Text(
              'No completed achievements yet. Progress updates will appear here in realtime.',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          ...recent.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildAchievementItem(
                icon: Icons.star_rounded,
                title: task.taskTitle,
                timeAgo: _relativeTime(_completionDate(task)),
              ),
            );
          }),
      ],
    );
  }

  Widget buildAchievementItem({
    required IconData icon,
    required String title,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1.27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.yellow, AppColors.yellowOrange],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.orange500, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.grey500,
            size: 20,
          ),
        ],
      ),
    );
  }

  int _resolveLevel(double points) {
    return math.max(1, (points / 250).floor() + 1);
  }

  double _resolveLevelProgress(double points) {
    final spent = (points / 250).floor() * 250;
    return ((points - spent) / 250).clamp(0.0, 1.0);
  }

  double _pointsToNextLevel(double points) {
    final nextThreshold = ((points / 250).floor() + 1) * 250;
    return math.max(0, nextThreshold - points).toDouble();
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
