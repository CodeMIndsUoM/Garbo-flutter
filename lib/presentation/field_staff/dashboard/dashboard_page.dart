import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/shared/stat_header.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/bin_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/widgets/achievement_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/shared/field_bottom_navigation.dart';
import 'package:garbo_swms/presentation/field_staff/bins/bins_page.dart';
import 'package:garbo_swms/presentation/field_staff/profile/profile_page.dart';
import 'package:garbo_swms/presentation/field_staff/bins/report_bin_page.dart';

import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  List<BinModel> _bins = [];
  String _userName = 'Field Staff';
  String _empId = '';
  int _dayStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmpIdAndFetch();
  }

  Future<void> _loadEmpIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _empId = prefs.getString('empId') ?? '';
    _userName = prefs.getString('empName') ?? 'Field Staff';
    _dayStreak = prefs.getInt('field_staff_day_streak') ?? 0;
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
      final prefs = await SharedPreferences.getInstance();
      final bins = await _apiService.getAssignedBins(_empId);
      final name = await _apiService.getFieldMentorName(_empId);
      final dayStreak = prefs.getInt('field_staff_day_streak') ?? 0;

      if (mounted) {
        setState(() {
          _bins = bins;
          _userName = name;
          _dayStreak = dayStreak;
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
  Widget build(BuildContext context) {
    final int pendingBins = _bins
        .where((b) => b.status == BinStatus.notChecked)
        .length;
    final int? avgResponseMinutes = _calculateAvgResponseMinutes(_bins);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          // Shared header across all tabs
          StatHeader(
            userName: _userName,
            toCheckCount: pendingBins,
            dayStreak: _dayStreak,
            avgResponseLabel: avgResponseMinutes == null
                ? '--'
                : '${avgResponseMinutes}m',
          ),
          // Main content area — switches based on bottom nav
          Expanded(child: _buildPage()),
          // Bottom navigation bar
          FieldBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
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
