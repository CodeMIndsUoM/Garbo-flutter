import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.grey700, size: 22),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.grey200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your account and app preferences',
              style: TextStyle(
                color: AppColors.grey500,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SettingsMenuItem(
              icon: Icons.settings_outlined,
              iconBgColor: const Color(0xFFEEF2FF),
              iconColor: const Color(0xFF6366F1),
              title: 'Account Settings',
              subtitle: 'Manage your profile and preferences',
              onTap: () {
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.notifications_outlined,
              iconBgColor: const Color(0xFFFFF7ED),
              iconColor: AppColors.orange500,
              title: 'Notifications',
              subtitle: 'Configure notification preferences',
              badge: '2',
              onTap: () {
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.history_rounded,
              iconBgColor: const Color(0xFFECFDF5),
              iconColor: AppColors.green700,
              title: 'History',
              subtitle: 'View your activity history',
              onTap: () {
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.shield_outlined,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: AppColors.red500,
              title: 'Privacy & Security',
              subtitle: 'Security settings and privacy controls',
              onTap: () {
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.help_outline_rounded,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: AppColors.red500,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.logout_rounded,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: AppColors.red500,
              title: 'Log Out',
              subtitle: 'Sign out and return to login',
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.login,
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const SettingsMenuItem({super.key, 
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grey200, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.grey900,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orange500,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.grey500,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
