import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_card.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_performance_grid.dart';
import 'package:garbo_swms/presentation/field_staff/profile/widgets/profile_achievement_list.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey50,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Using the new Profile Card with mockup data matching Figma
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ProfileCard(
                name: 'sasindu',
                role: 'Field Staff',
                employeeId: 'FS-2024-042',
                email: 'sasindu@gmail.com',
                joinedDate: 'Jan 15, 2024',
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
