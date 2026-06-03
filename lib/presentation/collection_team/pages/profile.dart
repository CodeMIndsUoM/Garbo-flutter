import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
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
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _performanceStatsTimeout = Duration(seconds: 20);

  bool _didLoadGamification = false;
  CollectorPerformanceStats? _performanceStats;
  bool _isPerformanceLoading = false;
  String? _performanceError;
  int? _activeUserId;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _performanceSocketSubscription;
  Timer? _performanceRefreshDebounce;
  Future<void>? _performanceLoadFuture;
  bool _queuedPerformanceReload = false;

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
        _refreshProfileProgress(gamificationProvider, userId);
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
        _refreshProfileProgress(
          context.read<GamificationTasksProvider>(),
          _activeUserId!,
        );
      });
    });
  }

  Future<void> _refreshProfileProgress(
    GamificationTasksProvider gamificationProvider,
    int userId,
  ) async {
    await gamificationProvider.loadUserTasks(userId);
    if (!mounted) {
      return;
    }
    await _loadPerformanceStats(userId);
  }

  @override
  void dispose() {
    _performanceRefreshDebounce?.cancel();
    _performanceSocketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPerformanceStats(int userId) async {
    if (_performanceLoadFuture != null && _activeUserId == userId) {
      _queuedPerformanceReload = true;
      return _performanceLoadFuture!;
    }

    setState(() {
      _isPerformanceLoading = _performanceStats == null;
      if (_performanceStats == null) {
        _performanceError = null;
      }
    });

    final future = _loadPerformanceStatsInternal(userId);
    _performanceLoadFuture = future;
    try {
      await future;
    } finally {
      if (identical(_performanceLoadFuture, future)) {
        _performanceLoadFuture = null;
      }
    }
  }

  Future<void> _loadPerformanceStatsInternal(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/$userId/performance-stats'),
            headers: headers,
          )
          .timeout(_performanceStatsTimeout);

      final decoded = jsonDecode(response.body);
      final body = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode != 200 || body['success'] != true) {
        setState(() {
          if (_performanceStats == null) {
            _performanceError =
                body['message']?.toString() ??
                body['error']?.toString() ??
                'Failed to load performance stats';
          }
          _isPerformanceLoading = false;
        });
        return;
      }

      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        setState(() {
          if (_performanceStats == null) {
            _performanceError = 'Invalid performance stats response';
          }
          _isPerformanceLoading = false;
        });
        return;
      }

      setState(() {
        _performanceStats = CollectorPerformanceStats.fromJson(data);
        _performanceError = null;
        _isPerformanceLoading = false;
      });
    } on TimeoutException catch (e) {
      setState(() {
        if (_performanceStats == null) {
          _performanceError = 'Failed to load performance stats: $e';
        }
        _isPerformanceLoading = false;
      });
      _schedulePerformanceStatsRetry(userId);
    } catch (e) {
      setState(() {
        if (_performanceStats == null) {
          _performanceError = 'Failed to load performance stats: $e';
        }
        _isPerformanceLoading = false;
      });
    } finally {
      if (_queuedPerformanceReload && _activeUserId == userId) {
        _queuedPerformanceReload = false;
        unawaited(_loadPerformanceStats(userId));
      }
    }
  }

  void _schedulePerformanceStatsRetry(int userId) {
    Future<void>.delayed(const Duration(seconds: 2), () async {
      if (!mounted || _activeUserId != userId) {
        return;
      }
      try {
        await _loadPerformanceStats(userId);
      } catch (_) {
        // Keep retry path quiet; realtime updates will trigger more refreshes.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
    final status = _formatDutyStatus(authUser);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 12,
            offset: Offset(0, 4),
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
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.grey900,
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
                        color: AppColors.grey900,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleLabel,
                      style: const TextStyle(color: AppColors.grey600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      idLabel,
                      style: const TextStyle(color: AppColors.grey500, fontSize: 12),
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

  String _formatDutyStatus(AppUser? user) {
    if (user == null) {
      return '--';
    }

    if (!user.onDuty) {
      return 'Off Duty';
    }

    final startedAtRaw = user.lastLoginAt ?? user.createdAt;
    if (startedAtRaw == null || startedAtRaw.trim().isEmpty) {
      return 'On Duty';
    }

    final startedAt = DateTime.tryParse(startedAtRaw);
    if (startedAt == null) {
      return 'On Duty';
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed.isNegative) {
      return 'On Duty';
    }

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);

    if (hours > 0) {
      return 'On Duty for ${hours}h ${minutes}m';
    }

    return 'On Duty for ${minutes}m';
  }

  Widget buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green700, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: AppColors.grey600, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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

        if (gamificationProvider.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  gamificationProvider.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.red500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
    final progressPercent = task.progressPercentage;
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (task.isNew) _buildNewBadge(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _shortTaskDescription(task.taskDescription),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                if (_buildTaskDuration(task) != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildTaskDuration(task)!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${task.pointsEarned.toStringAsFixed(0)} pts earned',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFEAB308),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w600,
                  ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.taskTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                if (_buildTaskDuration(task) != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildTaskDuration(task)!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${task.pointsEarned.toStringAsFixed(0)} pts earned',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFEAB308),
                        fontWeight: FontWeight.w700,
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
                  '${task.currentProgress.toStringAsFixed(0)}/${task.targetProgress.toStringAsFixed(0)} complete',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey500,
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
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.blue500,
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
