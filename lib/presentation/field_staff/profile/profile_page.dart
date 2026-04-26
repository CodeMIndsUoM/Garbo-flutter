import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_achievement_list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();

  String _name = 'Field Staff';
  String _role = 'Field Staff';
  String _employeeId = '-';
  String _email = '-';
  String _joinedDate = '-';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final empId = await _apiService.getStoredEmpId();
      final empName = await _apiService.getStoredEmpName();

      if (!mounted) return;

      setState(() {
        if (empName.trim().isNotEmpty) {
          _name = empName;
        }
        _employeeId = empId.trim().isNotEmpty ? empId : '-';
      });

      if (empId.trim().isEmpty) {
        return;
      }

      final profile = await _apiService.getUserProfile(empId);
      if (!mounted || profile == null) return;

      setState(() {
        final dbName = (profile['empName'] ?? '').toString().trim();
        final dbEmail = (profile['email'] ?? '').toString().trim();
        final dbRole = (profile['role'] ?? '').toString().trim();

        if (dbName.isNotEmpty) _name = dbName;
        if (dbEmail.isNotEmpty) _email = dbEmail;
        if (dbRole.isNotEmpty) {
          _role = dbRole
              .toLowerCase()
              .replaceAll('_', ' ')
              .split(' ')
              .where((part) => part.isNotEmpty)
              .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
              .join(' ');
        }

        _joinedDate = _formatJoinedDate(profile['createdAt']);
      });
    } catch (_) {
      // Keep fallbacks when profile loading fails.
    }
  }

  String _formatJoinedDate(dynamic rawCreatedAt) {
    if (rawCreatedAt == null) return '-';
    final value = rawCreatedAt.toString().trim();
    if (value.isEmpty) return '-';

    try {
      final parsed = DateTime.parse(value);
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
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey50,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ProfileCard(
                name: _name,
                role: _role,
                employeeId: _employeeId,
                email: _email,
                joinedDate: _joinedDate,
              ),
            ),

            // Performance Stats
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ProfilePerformanceGrid(),
            ),
            const SizedBox(height: 24),

            // Achievements
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ProfileAchievementList(),
            ),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
    );
  }
}
