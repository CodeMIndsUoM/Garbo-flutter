import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/field_staff/shared/stat_header.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/bin_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/achievement_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/shared/field_bottom_navigation.dart';
import 'package:garbo_swms/presentation/field_staff/bins/bins_page.dart';
import 'package:garbo_swms/presentation/field_staff/profile/profile_page.dart';
import 'package:garbo_swms/presentation/field_staff/bins/report_bin_page.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  List<BinModel> _bins = [];
  String _empId = '';
  bool _isLoading = true;
  bool _didAttachRealtimeListener = false;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _binStatusSocketSubscription;
  Timer? _dashboardRefreshDebounce;

  @override
  void initState() {
    super.initState();
    _loadEmpIdAndFetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAttachRealtimeListener) {
      return;
    }
    _didAttachRealtimeListener = true;
    _attachRealtimeDashboardRefresh(context.read<WebSocketProvider>());
  }

  void _attachRealtimeDashboardRefresh(WebSocketProvider webSocketProvider) {
    _binStatusSocketSubscription?.cancel();
    _binStatusSocketSubscription = webSocketProvider.messageStream.listen((
      message,
    ) {
      if (message.type != 'BIN_STATUS_UPDATED') {
        return;
      }

      final payload = message.payload;
      if (payload == null) {
        return;
      }

      // Ignore updates that are clearly for another mentor.
      final assignedToEmpId = int.tryParse(
        (payload['assignedToEmpId'] ?? '').toString(),
      );
      final currentEmpId = int.tryParse(_empId);
      if (assignedToEmpId != null &&
          currentEmpId != null &&
          assignedToEmpId != currentEmpId) {
        return;
      }

      // Debounce websocket bursts so multiple status changes trigger one reload.
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
      _fetchDashboardData(); // Refresh list if report was submitted
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
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PerformanceGrid(
            totalBins: totalBins,
            pendingBins: pendingBins,
            avgResponseMinutes: avgResponseMinutes,
          ),
          const SizedBox(height: 24),
          BinListSection(bins: _bins, onReport: _handleReport),
          const AchievementListSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
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
