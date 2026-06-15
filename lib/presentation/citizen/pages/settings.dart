import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';

class CitizenSettingsPage extends StatefulWidget {
  const CitizenSettingsPage({super.key});

  @override
  State<CitizenSettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<CitizenSettingsPage> {
  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CitizenHeader(name: 'Menu'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  buildMenuItems(),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 4),
    );
  }

  Widget buildMenuItems() {
    return Column(
      children: [
        buildMenuItem(
          icon: Icons.person_outline,
          title: 'My Profile',
          backgroundColor: AppColors.greenSurface2,
          iconColor: AppColors.green700,
          onTap: () {
            Navigator.pushNamed(context, AppRouter.citizenProfile);
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Account Settings',
          backgroundColor: AppColors.purple50,
          iconColor: AppColors.purple600,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account Settings coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          backgroundColor: AppColors.red50,
          iconColor: AppColors.red500,
          badge: '2 new',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.history,
          title: 'History',
          backgroundColor: AppColors.emerald50,
          iconColor: AppColors.emerald600,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('History coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.security_outlined,
          title: 'Privacy & Security',
          backgroundColor: AppColors.indigo50,
          iconColor: AppColors.blue700,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy & Security coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          backgroundColor: AppColors.emerald100,
          iconColor: AppColors.green700,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Help & Support coming soon'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          backgroundColor: AppColors.red50,
          iconColor: AppColors.red500,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Logout', style: AppTypography.titleLg),
                content: Text(
                  'Are you sure you want to logout?',
                  style: AppTypography.bodyMd,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Logged out successfully'),
                          backgroundColor: AppColors.green700,
                        ),
                      );
                    },
                    child: Text(
                      'Logout',
                      style: AppTypography.buttonMd.copyWith(
                        color: AppColors.red500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: AppTypography.titleMd),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: AppTypography.captionSm.copyWith(
                    color: AppColors.red500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (badge == null)
              Icon(
                Icons.chevron_right,
                color: AppColors.grey400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
