import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row (Title & Close Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Settings & More',
                    style: TextStyle(
                      color: AppColors.grey900,
                      fontSize: 20,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        color: AppColors.grey100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.grey600,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Big Title & Subtitle
              const Text(
                'Settings & More',
                style: TextStyle(
                  color: AppColors.grey900,
                  fontSize: 24,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your account and app preferences',
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              
              // Menu Options
              _buildOption(
                icon: Icons.settings_outlined,
                iconColor: AppColors.green700,
                iconBgColor: AppColors.emerald50,
                title: 'Account Settings',
                subtitle: 'Manage your profile and preferences',
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.notifications_none_outlined,
                iconColor: AppColors.green700,
                iconBgColor: AppColors.emerald50,
                title: 'Notifications',
                subtitle: 'Configure notification preferences',
                badgeCount: '2',
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.history,
                iconColor: AppColors.green700,
                iconBgColor: AppColors.emerald50,
                title: 'History',
                subtitle: 'View your activity history',
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.shield_outlined,
                iconColor: AppColors.green700,
                iconBgColor: AppColors.emerald50,
                title: 'Privacy & Security',
                subtitle: 'Security settings and privacy controls',
              ),
              const SizedBox(height: 12),
              _buildOption(
                icon: Icons.help_outline,
                iconColor: AppColors.green700,
                iconBgColor: AppColors.emerald50,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    String? badgeCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.27, color: AppColors.grey100),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 3,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: iconBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.grey900,
                        fontSize: 15,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (badgeCount != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: ShapeDecoration(
                          color: AppColors.purple500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          badgeCount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.grey400,
            size: 20,
          ),
        ],
      ),
    );
  }
}
