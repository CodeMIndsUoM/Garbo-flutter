import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/stat_header.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/bin_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/achievement_list_section.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/field_bottom_navigation.dart';
import 'package:garbo_swms/presentation/field_staff/pages/bin.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          // Shared header across all tabs
          const StatHeader(),
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
        // TODO: Replace with ProfilePage when implemented
        return const Center(
          child: Text(
            'Profile',
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
        );
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          PerformanceGrid(),
          SizedBox(height: 24),
          BinListSection(),
          AchievementListSection(),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
