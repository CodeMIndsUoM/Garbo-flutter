import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/utils/notification_provider_access.dart';
import 'package:garbo_swms/presentation/widgets/notifications_page.dart';

/// Notification bell with unread badge — used in app headers.
class NotificationBellButton extends StatelessWidget {
  final Color? iconColor;
  final double iconSize;

  const NotificationBellButton({
    super.key,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);
    final unreadCount = context.watchUnreadNotificationCount();

    return GestureDetector(
      onTap: () {
        context.pushAppPage(const NotificationsPage());
      },
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: iconColor ?? AppColors.grey900,
              size: iconSize,
            ),
            if (unreadCount > 0)
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
                    border: Border.all(
                      color: AppColors.background,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: unreadCount > 99 ? 8 : 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
