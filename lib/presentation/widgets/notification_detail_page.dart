import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/notification_navigation.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/core/utils/notification_provider_access.dart';
import 'package:garbo_swms/data/models/app_notification_model.dart';
import 'package:garbo_swms/presentation/widgets/notification_ui.dart';

class NotificationDetailPage extends StatelessWidget {
  final AppNotificationModel notification;

  const NotificationDetailPage({
    super.key,
    required this.notification,
  });

  static void open(BuildContext context, AppNotificationModel notification) {
    context.pushAppPage(NotificationDetailPage(notification: notification));
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final readOnly = NotificationUi.isReadOnlyAnnouncement(
      notification.type,
      notification.data,
    );
    final personalMessage = NotificationUi.isPersonalAdminMessage(notification.data);
    final showRelatedAction = NotificationUi.hasRelatedDestination(notification.type);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.grey900,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification',
          style: AppTypography.h2.copyWith(color: AppColors.grey900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.card(
                color: notification.read
                    ? AppColors.surface
                    : AppColors.surfaceVariant,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: NotificationUi.iconBackground(notification.type),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          NotificationUi.iconForType(notification.type),
                          color: NotificationUi.iconColor(notification.type),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personalMessage
                                  ? 'Personal message'
                                  : NotificationUi.typeLabel(notification.type),
                              style: AppTypography.captionSm.copyWith(
                                color: AppColors.grey500,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.title,
                              style: AppTypography.titleMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey900,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    NotificationUi.formatTimestampLong(notification.createdAt),
                    style: AppTypography.captionSm.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Message',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.card(color: AppColors.surface),
              child: Text(
                notification.body.isNotEmpty
                    ? notification.body
                    : 'No additional details.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.grey900,
                  height: 1.5,
                ),
              ),
            ),
            if (readOnly) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.blue500,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        NotificationUi.readOnlyAnnouncementHint(notification.data),
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.blue700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showRelatedAction) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    NotificationNavigation.openFromNotification(
                      context,
                      notification,
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('View related'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Opens the detail page and marks the notification as read when possible.
void openNotificationDetail(
  BuildContext context,
  AppNotificationModel notification,
) {
  if (!notification.read) {
    context.notificationProviderOrNull?.markAsRead(notification.id);
  }
  NotificationDetailPage.open(context, notification);
}
