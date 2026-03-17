import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          CitizenHeader(name: 'Menu'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  buildMenuItems(),
                  const SizedBox(height: 24),
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
          backgroundColor: AppColors.blue50,
          iconColor: AppColors.blue600,
          onTap: () {
            Navigator.pushNamed(context, AppRouter.citizenProfile);
          },
        ),
        const SizedBox(height: 12),
        buildMenuItem(
          icon: Icons.settings_outlined,
          title: 'Account Settings',
          backgroundColor: Color(0xFFF3E8FF),
          iconColor: Color(0xFF9333EA),
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
          backgroundColor: Color(0xFFFFEBEE),
          iconColor: Colors.red,
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
          backgroundColor: Color(0xFFE0E7FF),
          iconColor: Color(0xFF4F46E5),
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
          backgroundColor: Color(0xFFD1FAE5),
          iconColor: Color(0xFF10B981),
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
          backgroundColor: Colors.red.withOpacity(0.1),
          iconColor: Colors.red,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully'),
                          backgroundColor: AppColors.emerald600,
                        ),
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 6,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (badge == null)
              const Icon(
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
