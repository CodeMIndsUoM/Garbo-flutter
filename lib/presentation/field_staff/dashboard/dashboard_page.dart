import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/field_staff/shared/stat_header.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/bin_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/achievement_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/level_progress_card.dart';
import 'package:garbo_swms/presentation/field_staff/shared/field_bottom_navigation.dart';
import 'package:garbo_swms/presentation/field_staff/bins/bins_page.dart';
import 'package:garbo_swms/presentation/field_staff/profile/profile_page.dart';
import 'package:garbo_swms/presentation/field_staff/suggestions/suggest_bin_page.dart';
import 'package:garbo_swms/presentation/field_staff/bins/report_bin_page.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/gamification_tasks_provider.dart';
import 'package:garbo_swms/presentation/providers/leaderboard_provider.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  final int initialTabIndex;

  const Dashboard({super.key, this.initialTabIndex = 0});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int _selectedIndex;
  final ApiService _apiService = ApiService();
  List<BinModel> _bins = [];
  String _empId = '';
  bool _isLoading = true;
  bool _didAttachRealtimeListener = false;
  bool _didPrimeGamification = false;
  bool _didPrimeLeaderboard = false;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _binStatusSocketSubscription;
  Timer? _dashboardRefreshDebounce;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, 3);
    _loadEmpIdAndFetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAttachRealtimeListener) {
      _didAttachRealtimeListener = true;
      _attachRealtimeDashboardRefresh(context.read<WebSocketProvider>());
    }

    if (!_didPrimeGamification) {
      _didPrimeGamification = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _primeGamificationProviders();
      });
    }

    if (!_didPrimeLeaderboard) {
      _didPrimeLeaderboard = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _primeLeaderboardProvider();
      });
    }
  }

  void _primeGamificationProviders() {
    final authProvider = context.read<AuthProvider>();
    final gamificationProvider = context.read<GamificationTasksProvider>();
    final user = authProvider.currentUser;
    final userId = user?.empId ?? int.tryParse(_empId);
    final role = user?.role ?? 'FIELD_STAFF';

    if (userId != null) {
      gamificationProvider.loadUserTasks(userId);
      gamificationProvider.loadAvailableTasks(role);
    }
  }

  void _primeLeaderboardProvider() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.empId ?? int.tryParse(_empId);
    if (userId == null) {
      return;
    }

    context.read<LeaderboardProvider>().trackUser(
      userId,
      role: authProvider.currentUser?.role ?? 'FIELD_STAFF',
    );
  }

  void _attachRealtimeDashboardRefresh(WebSocketProvider webSocketProvider) {
    _binStatusSocketSubscription?.cancel();
    _binStatusSocketSubscription = webSocketProvider.messageStream.listen((
      message,
    ) {
      if (message.type == 'BIN_ASSIGNED') {
        _dashboardRefreshDebounce?.cancel();
        _dashboardRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
          if (mounted && _empId.isNotEmpty) {
            _fetchDashboardData();
          }
        });
        return;
      }

      if (message.type == 'TASK_PROGRESS_UPDATE' ||
          message.type == 'LEADERBOARD_UPDATE') {
        final messageUserId = message.userId;
        final currentEmpId = int.tryParse(_empId);
        if (messageUserId != null &&
            currentEmpId != null &&
            messageUserId != currentEmpId) {
          return;
        }
        if (mounted) {
          setState(() {});
        }
        return;
      }

      if (message.type != 'BIN_STATUS_UPDATED') {
        return;
      }

      final payload = message.payload;
      if (payload == null) {
        return;
      }

      final assignedToEmpId = int.tryParse(
        (payload['assignedToEmpId'] ?? '').toString(),
      );
      final currentEmpId = int.tryParse(_empId);
      if (assignedToEmpId != null &&
          currentEmpId != null &&
          assignedToEmpId != currentEmpId) {
        return;
      }

      _dashboardRefreshDebounce?.cancel();
      _dashboardRefreshDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!mounted || _empId.isEmpty) {
          return;
        }
        _fetchDashboardData();
      });
    });
  }

  Future<void> _loadEmpIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _empId = prefs.getString('empId') ?? '';
    if (_empId.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    await _fetchDashboardData();
    if (mounted) {
      _primeGamificationProviders();
      _primeLeaderboardProvider();
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final bins = await _apiService.getAssignedBins();

      if (mounted) {
        setState(() {
          _bins = bins;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 0 && _selectedIndex != 0) {
      _fetchDashboardData();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleReport(BinModel bin) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportBinPage(bin: bin, empId: _empId),
      ),
    );

    if (result == true) {
      _fetchDashboardData();
      final userId = int.tryParse(_empId);
      if (userId != null && mounted) {
        context.read<GamificationTasksProvider>().reloadUserTasks(userId);
      }
    }
  }

  @override
  void dispose() {
    _dashboardRefreshDebounce?.cancel();
    _binStatusSocketSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          StatHeader(title: _tabTitle()),
          Expanded(child: _buildPage()),
        ],
      ),
      bottomNavigationBar: FieldBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  String _tabTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Bins';
      case 2:
        return 'Suggest Bin';
      case 3:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const BinsPage();
      case 2:
        return const SuggestBinPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final int totalBins = _bins.length;
    final int pendingBins = _bins
        .where((b) => b.status == BinStatus.notChecked)
        .length;
    final int? avgResponseMinutes = _calculateAvgResponseMinutes(_bins);

    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final gamificationProvider = context.watch<GamificationTasksProvider>();
    final userEntry = leaderboardProvider.userRankEntry;
    final points = userEntry?.rewardPoints ?? 0.0;
    final level = _resolveLevel(points);
    final levelProgress = _resolveLevelProgress(points);
    final pointsToday = _pointsEarnedToday(gamificationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LevelProgressCard(
            userEntry: userEntry,
            level: level,
            points: points,
            levelProgress: levelProgress,
            pointsToNextLevel: _pointsToNextLevel(points),
          ),
          const SizedBox(height: 24),
          PerformanceGrid(
            totalBins: totalBins,
            pendingBins: pendingBins,
            avgResponseMinutes: avgResponseMinutes,
            pointsToday: pointsToday,
          ),
          const SizedBox(height: 24),
          BinListSection(bins: _bins, onReport: _handleReport),
          const SizedBox(height: 24),
          const AchievementListSection(),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  double _pointsEarnedToday(GamificationTasksProvider gamificationProvider) {
    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    String? extractDateKey(String? rawDate) {
      if (rawDate == null || rawDate.isEmpty) {
        return null;
      }
      final parsed = DateTime.tryParse(rawDate);
      if (parsed == null) {
        return null;
      }
      final local = parsed.toLocal();
      return '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}';
    }

    return gamificationProvider.completedTasks
        .where((task) => extractDateKey(task.completedAt) == todayKey)
        .fold<double>(0.0, (sum, task) => sum + task.pointsEarned);
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

  int? _calculateAvgResponseMinutes(List<BinModel> bins) {
    final now = DateTime.now();
    final checkedToday = bins.where((bin) {
      final lastChecked = bin.lastChecked;
      if (lastChecked == null) return false;
      return lastChecked.year == now.year &&
          lastChecked.month == now.month &&
          lastChecked.day == now.day;
    }).toList();

    if (checkedToday.isEmpty) {
      return null;
    }

    final totalMinutes = checkedToday
        .map((bin) => now.difference(bin.lastChecked!.toLocal()).inMinutes)
        .fold<int>(0, (sum, item) => sum + item);

    final avg = totalMinutes / checkedToday.length;
    if (avg.isNaN || avg.isInfinite) {
      return null;
    }
    return avg.round();
  }
}
