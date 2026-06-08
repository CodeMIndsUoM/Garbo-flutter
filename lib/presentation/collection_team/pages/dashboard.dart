import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/collection_team/pages/profile.dart';
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
  bool _didPrimeLeaderboard = false;

  bool _isSameDay(DateTime value, DateTime reference) {
    return value.year == reference.year &&
        value.month == reference.month &&
        value.day == reference.day;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrimeGamification) {
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

    if (!_didPrimeLeaderboard) {
      _didPrimeLeaderboard = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.currentUser?.empId;
        context.read<LeaderboardProvider>().trackUser(
          userId,
          role: authProvider.currentUser?.role,
        );
      });
    }
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

    final points = userEntry?.rewardPoints ?? 0.0;
    final level = _resolveLevel(points);
    final levelProgress = _resolveLevelProgress(points);

    return Scaffold(
      extendBody: true,
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
 
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
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
                      color: AppColors.greenSurface2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppColors.green700,
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
                      color: AppColors.green700,
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
              backgroundColor: AppColors.grey100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.green700,
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

    final sessionsToday = routeProvider.routeHistory
        .where((session) => _isSameDay(session.generatedAt, now))
        .toList(growable: false);

    final assignedBins = sessionsToday.fold<int>(
      0,
      (sum, session) => sum + session.totalStops,
    );
    final collectedBins = sessionsToday.fold<int>(
      0,
      (sum, session) => sum + routeProvider.getCollectedCount(session.sessionId),
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

    final todayLabel = _formatDateShort(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Performance • $todayLabel",
          style: const TextStyle(
            color: AppColors.grey900,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              buildPerformanceItem(
                icon: Icons.delete_sweep_outlined,
                value: '$collectedBins',
                label: 'Bins Collected',
              ),
              const SizedBox(width: 12),
              buildPerformanceItem(
                icon: Icons.assignment_outlined,
                value: '$routesDone',
                label: 'Routes Done',
              ),
              const SizedBox(width: 12),
              buildPerformanceItem(
                icon: Icons.speed_outlined,
                value: '${efficiency.toStringAsFixed(0)}%',
                label: 'Efficiency',
              ),
              const SizedBox(width: 12),
              buildPerformanceItem(
                icon: Icons.emoji_events_outlined,
                value: livePoints.toStringAsFixed(0),
                label: 'Live Points',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPerformanceItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green700, size: 22),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
    final now = DateTime.now();
    final sessions = routeProvider.routeHistory
        .where((session) => _isSameDay(session.generatedAt, now))
        .toList(growable: false)
        .reversed
        .take(2)
        .toList(growable: false);

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
                    ? const [AppColors.greenSurface2, AppColors.greenSurface3]
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey200,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSm,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
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
                context: context,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String timeAgo,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CollectionTeamProfile()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSm,
                blurRadius: 3,
                offset: Offset(0, 1),
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
        ),
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
