import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/app_notification_model.dart';
import 'package:garbo_swms/core/utils/notification_provider_access.dart';
import 'package:garbo_swms/presentation/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.notificationProviderOrNull?.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    try {
      final provider = context.watch<NotificationProvider>();
      return _NotificationsScaffold(provider: provider);
    } on ProviderNotFoundException {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: AppTypography.h2.copyWith(color: AppColors.grey900),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Restart the app (press R in the terminal) to load notifications.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }
}

class _NotificationsScaffold extends StatelessWidget {
  final NotificationProvider provider;

  const _NotificationsScaffold({required this.provider});

  @override
  Widget build(BuildContext context) {
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.grey900,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.h2.copyWith(color: AppColors.grey900),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.green700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: provider.isLoading && notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  _EmptyState(),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _NotificationTile(
                    notification: notifications[index],
                    onTap: () {
                      if (!notifications[index].read) {
                        provider.markAsRead(notifications[index].id);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.grey400,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No new notifications',
          style: AppTypography.titleMd.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "You'll see updates and alerts here.",
          style: AppTypography.bodySm.copyWith(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dt = notification.createdAt.toLocal();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final timeLabel =
        '${_month(dt.month)} ${dt.day}, $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: AppDecorations.card(
            color: notification.read
                ? AppColors.surface
                : AppColors.surfaceVariant,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBg(notification.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: _iconColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.titleSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.green700,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: AppTypography.captionSm.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'ROUTE_UPDATE':
      case 'ROUTE':
        return Icons.route_outlined;
      case 'BIN':
      case 'BIN_STATUS_UPDATED':
        return Icons.delete_outline;
      case 'JOB':
      case 'OFFER':
        return Icons.work_outline;
      case 'LEADERBOARD':
        return Icons.emoji_events_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconBg(String type) {
    switch (type.toUpperCase()) {
      case 'ROUTE_UPDATE':
      case 'ROUTE':
        return AppColors.blue50;
      case 'BIN':
      case 'BIN_STATUS_UPDATED':
        return AppColors.amberSurface;
      case 'JOB':
      case 'OFFER':
        return AppColors.emerald50;
      default:
        return AppColors.grey100;
    }
  }

  Color _iconColor(String type) {
    switch (type.toUpperCase()) {
      case 'ROUTE_UPDATE':
      case 'ROUTE':
        return AppColors.blue500;
      case 'BIN':
      case 'BIN_STATUS_UPDATED':
        return AppColors.amber600;
      case 'JOB':
      case 'OFFER':
        return AppColors.green700;
      default:
        return AppColors.grey600;
    }
  }

  static String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }
}
