import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';
import 'package:garbo_swms/data/models/performance_stats_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/bottom_navigation.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

class CollectionTeamProfile extends StatefulWidget {
  const CollectionTeamProfile({super.key});

  @override
  State<CollectionTeamProfile> createState() => _CollectionTeamProfileState();
}

class _CollectionTeamProfileState extends State<CollectionTeamProfile> {
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080',
  );

  bool _didLoadGamification = false;
  CollectorPerformanceStats? _performanceStats;
  bool _isPerformanceLoading = false;
  String? _performanceError;
  int? _activeUserId;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _performanceSocketSubscription;
  Timer? _performanceRefreshDebounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadGamification) {
      return;
    }

    _didLoadGamification = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final gamificationProvider = context.read<GamificationTasksProvider>();

      final userId = authProvider.currentUser?.empId;
      final role = authProvider.currentUser?.role;

      if (userId != null) {
        _activeUserId = userId;
        gamificationProvider.loadUserTasks(userId);
        _loadPerformanceStats(userId);
      }
      if (role != null && role.isNotEmpty) {
        gamificationProvider.loadAvailableTasks(role);
      }

      _attachPerformanceRealtimeRefresh(context.read<WebSocketProvider>());
    });
  }

  void _attachPerformanceRealtimeRefresh(WebSocketProvider webSocketProvider) {
    _performanceSocketSubscription?.cancel();
    _performanceSocketSubscription = webSocketProvider.messageStream.listen((message) {
      if (_activeUserId == null) {
        return;
      }

      final type = message.type.toUpperCase();
      final shouldRefresh = type == 'BIN_COLLECTION_ACK' ||
          type == 'TASK_PROGRESS_UPDATE' ||
          type == 'LEADERBOARD_UPDATE';

      if (!shouldRefresh) {
        return;
      }

      final messageUserId = message.userId;
      if (messageUserId != null && messageUserId != _activeUserId) {
        return;
      }

      _performanceRefreshDebounce?.cancel();
      _performanceRefreshDebounce = Timer(const Duration(milliseconds: 600), () {
        if (!mounted || _activeUserId == null) {
          return;
        }
        _loadPerformanceStats(_activeUserId!);
      });
    });
  }

  @override
  void dispose() {
    _performanceRefreshDebounce?.cancel();
    _performanceSocketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPerformanceStats(int userId) async {
    setState(() {
      _isPerformanceLoading = true;
      _performanceError = null;
    });

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/users/$userId/performance-stats'))
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['success'] != true) {
        setState(() {
          _performanceStats = null;
          _performanceError =
              body['message']?.toString() ?? 'Failed to load performance stats';
          _isPerformanceLoading = false;
        });
        return;
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        setState(() {
          _performanceStats = null;
          _performanceError = 'Invalid performance stats response';
          _isPerformanceLoading = false;
        });
        return;
      }

      setState(() {
        _performanceStats = CollectorPerformanceStats.fromJson(data);
        _performanceError = null;
        _isPerformanceLoading = false;
      });
    } catch (e) {
      setState(() {
        _performanceStats = null;
        _performanceError = 'Failed to load performance stats: $e';
        _isPerformanceLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          HeaderReduced(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildProfileCard(),
                  const SizedBox(height: 24),
                  buildPerformanceStats(),
                  const SizedBox(height: 24),
                  buildAchievements(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 3),
    );
  }

  Widget buildProfileCard() {
    final authUser = context.watch<AuthProvider>().currentUser;
    final fullName = (authUser?.empName ?? '').trim().isNotEmpty
      ? authUser!.empName
      : 'Collection Team Member';
    final roleLabel = _formatRoleLabel(authUser?.role);
    final idLabel = authUser != null ? 'ID: ${authUser.empId}' : 'ID: --';
    final initials = _buildInitials(fullName);
    final email = (authUser?.email ?? '').trim().isNotEmpty
      ? authUser!.email
      : '--';
    final joined = _formatJoinedDate(authUser?.createdAt);
    final status = authUser == null
      ? '--'
      : (authUser.onDuty ? 'On Duty' : 'Off Duty');

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.green700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.green700.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleLabel,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      idLabel,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: buildInfoItem(
                  Icons.email_outlined,
                  'Email',
                  email,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildInfoItem(
                  Icons.local_shipping_outlined,
                  'Role',
                  roleLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildInfoItem(
                  Icons.calendar_today_outlined,
                  'Joined',
                  joined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildInfoItem(
                  Icons.access_time_outlined,
                  'Status',
                  status,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildInitials(String fullName) {
    final parts = fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '--';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _formatRoleLabel(String? role) {
    if (role == null || role.trim().isEmpty) {
      return 'Collector';
    }
    final normalized = role.trim().toUpperCase();
    if (normalized == 'BIN_COLLECTOR' ||
        normalized == 'COLLECTION_TEAM' ||
        normalized == 'COLLECTOR') {
      return 'Collector';
    }
    if (normalized == 'FIELD_MENTOR' || normalized == 'MENTOR') {
      return 'Field Mentor';
    }
    return role;
  }

  String _formatJoinedDate(String? createdAt) {
    if (createdAt == null || createdAt.trim().isEmpty) {
      return '--';
    }
    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return '--';
    }
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
    final month = monthNames[parsed.month - 1];
    return '$month ${parsed.day}, ${parsed.year}';
  }

  Widget buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildPerformanceStats() {
    final stats = _performanceStats;
    final totalCollectedText = stats != null ? '${stats.totalCollected}' : '--';
    final routesDoneText = stats != null ? '${stats.routesDone}' : '--';
    final avgRouteTimeText = stats != null
      ? _formatDuration(stats.averageRouteTimeSeconds)
      : '--';
    final efficiencyText = stats != null
        ? '${stats.efficiencyPercent.toStringAsFixed(1)}%'
        : '--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Performance Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isPerformanceLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_performanceError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _performanceError!,
                style: const TextStyle(
                  color: AppColors.red500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: buildStatBox(
                  totalCollectedText,
                  'Total Collected',
                  AppColors.green700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildStatBox(
                  routesDoneText,
                  'Routes Done',
                  AppColors.blue500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildStatBox(
                  avgRouteTimeText,
                  'All-time Avg Route Time',
                  const Color(0xFFD946EF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildStatBox(
                  efficiencyText,
                  'Efficiency',
                  AppColors.orange500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.grey600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDuration(double totalSeconds) {
    final duration = Duration(seconds: totalSeconds.round().clamp(0, 1 << 31));
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    }
    return '${seconds}s';
  }

  Widget buildAchievements() {
    return Consumer<GamificationTasksProvider>(
      builder: (context, gamificationProvider, _) {
        final completedTasks = gamificationProvider.completedTasks;
        final ongoingTasks = gamificationProvider.ongoingTasks;
        final totalTasks = gamificationProvider.totalTasks;
        final totalCompleted = gamificationProvider.totalCompleted;

        if (gamificationProvider.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFEAB308),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with count badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFEAB308),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalCompleted/$totalTasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Completed tasks section
              if (completedTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
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
                      painter: DashedLinePainter(color: AppColors.grey300),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Ongoing tasks section
              if (ongoingTasks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'In Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
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
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Great job! You\'ve completed all tasks.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build a completed task card with green checkmark
  Widget _buildCompletedTaskCard(UserTaskProgress task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.green700.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.green700,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.taskDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.check,
                      color: AppColors.green700,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.green700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '+${task.pointsEarned.toStringAsFixed(0)} pts',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.green700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.green700,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Build an ongoing task card with progress bar
  Widget _buildOngoingTaskCard(UserTaskProgress task) {
    final progressPercent = task.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.grey400,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.taskTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.taskDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(fontSize: 11, color: AppColors.grey500),
                    ),
                    const Spacer(),
                    Text(
                      '${task.currentProgress.toStringAsFixed(0)}/${task.targetProgress.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                  '${progressPercent.toStringAsFixed(0)}% complete',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

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
