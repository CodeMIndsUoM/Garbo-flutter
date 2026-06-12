import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/widgets/notification_bell_button.dart';

class ThirdPartyHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ThirdPartyHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 10,
        24,
        10,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.h1.copyWith(color: AppColors.grey900),
            ),
          ),
          const NotificationBellButton(iconSize: 24),
        ],
      ),
    );
  }
}
