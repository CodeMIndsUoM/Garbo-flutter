import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/performance_stats_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/bottom_navigation.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_logout_button.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_nav_button.dart';
import 'package:garbo_swms/presentation/collection_team/pages/leaderboard.dart';
import 'package:garbo_swms/presentation/collection_team/pages/achievements_page.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_page_body.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_stats_section.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/shared/profile/profile_edit_sheet.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

class CollectionTeamProfile extends StatefulWidget {
  const CollectionTeamProfile({super.key});

  @override
  State<CollectionTeamProfile> createState() => _CollectionTeamProfileState();
}

class _CollectionTeamProfileState extends State<CollectionTeamProfile> {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _performanceStatsTimeout = Duration(seconds: 20);
  final ApiService _apiService = ApiService();

  bool _didInitProfile = false;
  bool _achievementsLoaded = false;
  bool _achievementsLoading = false;
  String? _avatarUrl;
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
    if (_didInitProfile) {
      return;
    }

    _didInitProfile = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.empId;

      if (userId != null) {
        _activeUserId = userId;
        _loadPerformanceStats(userId);
        _loadAvatar(userId);
        context.read<LeaderboardProvider>().trackUser(
          userId,
          role: authProvider.currentUser?.role ?? 'COLLECTOR',
        );
        _loadAchievementsIfNeeded();
      }

      _attachPerformanceRealtimeRefresh(context.read<WebSocketProvider>());
    });
  }

  Future<void> _loadAvatar(int userId) async {
    final profile = await _apiService.getUserProfile('$userId');
    if (!mounted || profile == null) return;
    final avatar = (profile['avatarUrl'] ?? '').toString();
    setState(() => _avatarUrl = avatar.isEmpty ? null : avatar);
  }

  void _openEditSheet(String employeeId, String name, String phone) {
    showUserProfileEditSheet(
      context: context,
      apiService: _apiService,
      userId: employeeId,
      avatarUrl: _avatarUrl,
      initial: ProfileEditFields(name: name, phone: phone),
      onUpdated: () => _loadAvatar(int.parse(employeeId)),
    );
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
        if (_achievementsLoaded) {
          context.read<GamificationTasksProvider>().loadUserTasks(
            _activeUserId!,
          );
        }
      });
    });
  }

  Future<void> _loadAchievementsIfNeeded() async {
    if (_achievementsLoaded || _achievementsLoading || _activeUserId == null) {
      return;
    }

    setState(() => _achievementsLoading = true);

    final gamificationProvider = context.read<GamificationTasksProvider>();
    final role = context.read<AuthProvider>().currentUser?.role;

    try {
      if (role != null && role.isNotEmpty) {
        await gamificationProvider.loadAvailableTasks(role);
      }
      await gamificationProvider.loadUserTasks(_activeUserId!);
      if (mounted) {
        setState(() {
          _achievementsLoaded = true;
          _achievementsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _achievementsLoading = false);
      }
    }
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
    final authUser = context.watch<AuthProvider>().currentUser;
    final fullName = (authUser?.empName ?? '').trim().isNotEmpty
        ? authUser!.empName
        : 'Collection Team Member';
    final roleLabel = _formatRoleLabel(authUser?.role);
    final email = (authUser?.email ?? '').trim().isNotEmpty
        ? authUser!.email
        : '-';
    final joined = _formatJoinedDate(authUser?.createdAt);
    final status = _formatDutyStatus(authUser);
    final employeeId =
        authUser != null ? '${authUser.empId}' : '-';

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const HeaderReduced(title: 'Profile'),
          Expanded(
            child: ProfilePageBody(
              profileCard: ProfileCard(
                name: fullName,
                role: roleLabel,
                employeeId: employeeId,
                email: email,
                joinedDate: joined,
                avatarUrl: _avatarUrl,
                onEditTap: employeeId != '-'
                    ? () => _openEditSheet(employeeId, fullName, '')
                    : null,
              ),
              sections: [
                _buildPerformanceStatsSection(status),
                _buildLeaderboardSection(),
                _buildAchievementsSection(),
              ],
              footer: const ProfileLogoutButton(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 3),
    );
  }

  Widget _buildPerformanceStatsSection(String dutyStatus) {
    final stats = _performanceStats;
    final totalCollectedText =
        stats != null ? '${stats.totalCollected}' : '--';
    final routesDoneText = stats != null ? '${stats.routesDone}' : '--';
    final avgRouteTimeText = stats != null
        ? _formatDuration(stats.averageRouteTimeSeconds)
        : '--';
    final efficiencyText = stats != null
        ? '${stats.efficiencyPercent.toStringAsFixed(1)}%'
        : '--';

    Widget? topWidget;
    if (_isPerformanceLoading) {
      topWidget = const LinearProgressIndicator(minHeight: 3);
    } else if (_performanceError != null) {
      topWidget = Text(
        _performanceError!,
        style: const TextStyle(
          color: AppColors.red500,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return ProfileStatsSection(
      topWidget: topWidget,
      rows: [
        ProfileStatRow(label: 'Total Collected', value: totalCollectedText),
        ProfileStatRow(label: 'Routes Done', value: routesDoneText),
        ProfileStatRow(
          label: 'All-time Avg Route Time',
          value: avgRouteTimeText,
        ),
        ProfileStatRow(label: 'Efficiency', value: efficiencyText),
        ProfileStatRow(label: 'Duty Status', value: dutyStatus),
      ],
    );
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

  Widget _buildLeaderboardSection() {
    return Consumer<LeaderboardProvider>(
      builder: (context, leaderboardProvider, _) {
        final userEntry = leaderboardProvider.userRankEntry;
        final subtitle = userEntry != null
            ? 'Rank #${userEntry.rank} • ${userEntry.rewardPoints.toStringAsFixed(0)} pts'
            : 'Top earners and your rank';

        return ProfileNavButton(
          title: 'Leaderboard',
          icon: Icons.emoji_events_outlined,
          subtitle: subtitle,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LeaderboardPage()),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsSection() {
    return Consumer<GamificationTasksProvider>(
      builder: (context, gamificationProvider, _) {
        final totalTasks = gamificationProvider.totalTasks;
        final totalCompleted = gamificationProvider.totalCompleted;
        final subtitle = _achievementsLoaded && totalTasks > 0
            ? '$totalCompleted of $totalTasks completed'
            : 'Completed & in-progress tasks';

        return ProfileNavButton(
          title: 'Achievements',
          icon: Icons.emoji_events_outlined,
          subtitle: subtitle,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AchievementsPage()),
            );
          },
        );
      },
    );
  }
}
