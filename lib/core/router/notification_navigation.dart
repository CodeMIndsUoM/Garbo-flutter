import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/page_transitions.dart';
import 'package:garbo_swms/data/models/app_notification_model.dart';
import 'package:garbo_swms/presentation/citizen/pages/events.dart';
import 'package:garbo_swms/presentation/citizen/pages/report.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/request_page.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes.dart';
import 'package:garbo_swms/presentation/field_staff/dashboard/dashboard_page.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/browse.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs.dart';

/// Navigates to the screen that best matches a notification type + payload.
class NotificationNavigation {
  static void openFromNotification(
    BuildContext context,
    AppNotificationModel notification,
  ) {
    final type = notification.type.toUpperCase();

    final fieldStaffTab = _fieldStaffTabForType(type);
    if (fieldStaffTab != null) {
      _openFieldStaffDashboard(context, fieldStaffTab);
      return;
    }

    final destination = _destinationForType(type);
    if (destination == null) return;

    context.pushAppPage(destination);
  }

  /// Field staff tabs live inside [Dashboard]; opening them as a pushed shell
  /// page hides the bottom navigation bar.
  static int? _fieldStaffTabForType(String type) {
    switch (type) {
      case 'BIN_ASSIGNED':
        return 1;
      case 'BIN_SUGGESTION_RESOLVED':
        return 2;
      default:
        return null;
    }
  }

  static void _openFieldStaffDashboard(BuildContext context, int tabIndex) {
    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(page: Dashboard(initialTabIndex: tabIndex)),
      (route) => false,
    );
  }

  static Widget? _destinationForType(String type) {
    switch (type) {
      case 'ROUTE_ASSIGNED':
      case 'ROUTE_UPDATED':
        return const CollectionTeamRoutes();
      case 'MARKETPLACE_REQUEST_UPDATED':
        return const CitizenRequestPage();
      case 'MARKETPLACE_OFFER_UPDATED':
        return const ThirdPartyMyJobsPage();
      case 'COMPLAINT_STATUS_UPDATED':
      case 'COMPLAINT_SUBMITTED':
        return const CitizenReportPage();
      case 'EVENT_SUGGESTION_RESOLVED':
      case 'EVENT_SUGGESTION_SUBMITTED':
        return const CitizenPublicEventsPage();
      case 'REGISTRATION_APPROVED':
      case 'REGISTRATION_REJECTED':
        return const ThirdPartyBrowsePage();
      default:
        return null;
    }
  }
}
