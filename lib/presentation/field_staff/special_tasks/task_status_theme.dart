import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

/// Status and urgency styling theme for field staff special tasks / complaints.
abstract final class TaskStatusTheme {
  /// Top card accent bar color matching the status.
  static Color accent(String? status) {
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return AppColors.blue500;
      case 'RESOLVED':
      case 'APPROVED':
      case 'ACCEPTED':
        return AppColors.green700;
      case 'REJECTED':
      case 'REJECTED_BY_STAFF':
        return AppColors.red500;
      case 'ADDED_TO_ROUTE':
      case 'ROUTED':
        return AppColors.purple600;
      case 'PENDING':
      default:
        return AppColors.amber600;
    }
  }

  /// Status badge text color.
  static Color text(String? status) {
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return AppColors.blue600;
      case 'RESOLVED':
      case 'APPROVED':
      case 'ACCEPTED':
        return AppColors.green700;
      case 'REJECTED':
      case 'REJECTED_BY_STAFF':
        return AppColors.red500;
      case 'ADDED_TO_ROUTE':
      case 'ROUTED':
        return AppColors.purple600;
      case 'PENDING':
      default:
        return AppColors.amberDark;
    }
  }

  /// Status badge subtle surface fill.
  static Color surface(String? status) {
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return AppColors.blue50;
      case 'RESOLVED':
      case 'APPROVED':
      case 'ACCEPTED':
        return AppColors.greenSurface2;
      case 'REJECTED':
      case 'REJECTED_BY_STAFF':
        return AppColors.redSurface2;
      case 'ADDED_TO_ROUTE':
      case 'ROUTED':
        return AppColors.purple50;
      case 'PENDING':
      default:
        return AppColors.amberSurface;
    }
  }

  /// Status badge subtle border.
  static Color badgeBorder(String? status) {
    return text(status).withValues(alpha: 0.25);
  }

  /// Overlay card background.
  static Color cardBackground(String? status) {
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return AppColors.blue50;
      case 'RESOLVED':
      case 'APPROVED':
      case 'ACCEPTED':
        return AppColors.greenSurface3;
      case 'REJECTED':
      case 'REJECTED_BY_STAFF':
        return AppColors.redSurface2;
      case 'ADDED_TO_ROUTE':
      case 'ROUTED':
        return AppColors.purple50;
      case 'PENDING':
      default:
        return AppColors.amberSurface;
    }
  }

  /// Overlay card border.
  static Color cardBorder(String? status) {
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return AppColors.blue200;
      case 'RESOLVED':
      case 'APPROVED':
      case 'ACCEPTED':
        return AppColors.greenBorder2;
      case 'REJECTED':
      case 'REJECTED_BY_STAFF':
        return AppColors.red100;
      case 'ADDED_TO_ROUTE':
      case 'ROUTED':
        return AppColors.purple200;
      case 'PENDING':
      default:
        return AppColors.amberBorder;
    }
  }

  /// Overlay card primary text / icon fill.
  static Color cardText(String? status) {
    return text(status);
  }

  /// Status Icon for sheets and detail views.
  static IconData statusIcon(String? status) {
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return Icons.pending_actions_rounded;
      case 'RESOLVED':
      case 'APPROVED':
      case 'ACCEPTED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
      case 'REJECTED_BY_STAFF':
        return Icons.cancel_rounded;
      case 'ADDED_TO_ROUTE':
      case 'ROUTED':
        return Icons.alt_route_rounded;
      case 'PENDING':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  /// Formats raw status strings into human-friendly capitalized text.
  static String formatStatus(String? status) {
    if (status == null || status.trim().isEmpty) return 'Unknown';
    final normalized = _normalize(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      case 'APPROVED':
        return 'Approved';
      case 'ACCEPTED':
        return 'Accepted';
      case 'REJECTED':
        return 'Rejected';
      case 'REJECTED_BY_STAFF':
        return 'Rejected by Staff';
      case 'ADDED_TO_ROUTE':
        return 'Added to Route';
      case 'ROUTED':
        return 'Routed';
      case 'PENDING':
        return 'Pending';
      default:
        return status
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
            .join(' ');
    }
  }

  /// Urgency color.
  static Color urgencyColor(String? urgency) {
    if (urgency == null) return AppColors.grey500;
    final lower = urgency.trim().toLowerCase();
    if (lower.contains('high') || lower.contains('critical') || lower.contains('urgent')) {
      return AppColors.red500;
    }
    if (lower.contains('med')) {
      return AppColors.amberDark;
    }
    if (lower.contains('low')) {
      return AppColors.green700;
    }
    return AppColors.grey600;
  }

  /// Urgency background surface.
  static Color urgencyBackground(String? urgency) {
    if (urgency == null) return AppColors.surfaceVariant;
    final lower = urgency.trim().toLowerCase();
    if (lower.contains('high') || lower.contains('critical') || lower.contains('urgent')) {
      return AppColors.red50;
    }
    if (lower.contains('med')) {
      return AppColors.amberSurface;
    }
    if (lower.contains('low')) {
      return AppColors.greenSurface2;
    }
    return AppColors.surfaceVariant;
  }

  static String _normalize(String? status) {
    return status?.trim().toUpperCase() ?? '';
  }
}
