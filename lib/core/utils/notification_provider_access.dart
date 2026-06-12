import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/presentation/providers/notification_provider.dart';

/// Safe access when [NotificationProvider] may be absent (e.g. after hot reload).
extension NotificationProviderAccess on BuildContext {
  NotificationProvider? get notificationProviderOrNull {
    try {
      return read<NotificationProvider>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  int watchUnreadNotificationCount() {
    try {
      return watch<NotificationProvider>().unreadCount;
    } on ProviderNotFoundException {
      return 0;
    }
  }
}
