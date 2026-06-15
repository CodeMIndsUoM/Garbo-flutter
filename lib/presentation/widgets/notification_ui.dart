import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class NotificationUi {
  static String formatTimestamp(DateTime dateTime) {
    final dt = dateTime.toLocal();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_month(dt.month)} ${dt.day}, $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String formatTimestampLong(DateTime dateTime) {
    final dt = dateTime.toLocal();
    final weekday = _weekday(dt.weekday);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$weekday, ${_month(dt.month)} ${dt.day}, ${dt.year} · '
        '$hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN_MESSAGE':
        return 'Admin announcement';
      case 'BIN_ASSIGNED':
        return 'Bin assigned';
      case 'BIN_SUGGESTION_RESOLVED':
        return 'Suggestion update';
      case 'ROUTE_ASSIGNED':
        return 'Route assigned';
      case 'ROUTE_UPDATED':
        return 'Route updated';
      case 'MARKETPLACE_REQUEST_UPDATED':
        return 'Request update';
      case 'MARKETPLACE_OFFER_UPDATED':
        return 'Offer update';
      case 'COMPLAINT_STATUS_UPDATED':
        return 'Complaint update';
      case 'EVENT_SUGGESTION_RESOLVED':
        return 'Event update';
      case 'REGISTRATION_APPROVED':
        return 'Registration approved';
      case 'REGISTRATION_REJECTED':
        return 'Registration rejected';
      default:
        return type.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  static IconData iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'ROUTE_ASSIGNED':
      case 'ROUTE_UPDATED':
      case 'ROUTE_UPDATE':
      case 'ROUTE':
        return Icons.route_outlined;
      case 'BIN_ASSIGNED':
      case 'BIN':
      case 'BIN_STATUS_UPDATED':
        return Icons.delete_outline;
      case 'MARKETPLACE_REQUEST_UPDATED':
      case 'MARKETPLACE_OFFER_UPDATED':
      case 'JOB':
      case 'OFFER':
        return Icons.work_outline;
      case 'LEADERBOARD':
        return Icons.emoji_events_outlined;
      case 'ADMIN_MESSAGE':
        return Icons.campaign_outlined;
      case 'COMPLAINT_STATUS_UPDATED':
      case 'COMPLAINT_SUBMITTED':
        return Icons.report_problem_outlined;
      case 'EVENT_SUGGESTION_RESOLVED':
      case 'EVENT_SUGGESTION_SUBMITTED':
        return Icons.event_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color iconBackground(String type) {
    switch (type.toUpperCase()) {
      case 'ROUTE_ASSIGNED':
      case 'ROUTE_UPDATED':
      case 'ROUTE_UPDATE':
      case 'ROUTE':
      case 'ADMIN_MESSAGE':
        return AppColors.blue50;
      case 'BIN_ASSIGNED':
      case 'BIN':
      case 'BIN_STATUS_UPDATED':
        return AppColors.amberSurface;
      case 'MARKETPLACE_REQUEST_UPDATED':
      case 'MARKETPLACE_OFFER_UPDATED':
      case 'JOB':
      case 'OFFER':
        return AppColors.emerald50;
      default:
        return AppColors.grey100;
    }
  }

  static Color iconColor(String type) {
    switch (type.toUpperCase()) {
      case 'ROUTE_ASSIGNED':
      case 'ROUTE_UPDATED':
      case 'ROUTE_UPDATE':
      case 'ROUTE':
      case 'ADMIN_MESSAGE':
        return AppColors.blue500;
      case 'BIN_ASSIGNED':
      case 'BIN':
      case 'BIN_STATUS_UPDATED':
        return AppColors.amber600;
      case 'MARKETPLACE_REQUEST_UPDATED':
      case 'MARKETPLACE_OFFER_UPDATED':
      case 'JOB':
      case 'OFFER':
        return AppColors.green700;
      default:
        return AppColors.grey600;
    }
  }

  static bool isReadOnlyAnnouncement(String type, Map<String, dynamic>? data) {
    if (type.toUpperCase() == 'ADMIN_MESSAGE') return true;
    return data?['readOnly'] == true;
  }

  static bool isPersonalAdminMessage(Map<String, dynamic>? data) {
    return data?['targeted'] == true;
  }

  static String readOnlyAnnouncementHint(Map<String, dynamic>? data) {
    if (isPersonalAdminMessage(data)) {
      return 'This is a personal one-way message from your council admin. Replies are not supported.';
    }
    return 'This is a one-way announcement from your council admin. Replies are not supported.';
  }

  static bool hasRelatedDestination(String type) {
    return type.toUpperCase() != 'ADMIN_MESSAGE';
  }

  static String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }

  static String _weekday(int day) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[day - 1];
  }
}
