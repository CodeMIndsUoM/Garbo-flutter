import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class ThirdPartyHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const ThirdPartyHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 14,
        20,
        18,
      ),
      decoration: const BoxDecoration(
        color: AppColors.grey50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h1.copyWith(color: AppColors.grey900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.grey900,
                    size: 24,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: AppColors.red500,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          notificationCount > 9 ? '9+' : '$notificationCount',
                          textAlign: TextAlign.center,
                          style: AppTypography.badge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
