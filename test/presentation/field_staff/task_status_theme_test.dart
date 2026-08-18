import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/task_status_theme.dart';

void main() {
  group('TaskStatusTheme Tests', () {
    test('accent colors for various statuses', () {
      expect(TaskStatusTheme.accent('IN_PROGRESS'), AppColors.blue500);
      expect(TaskStatusTheme.accent('in_progress'), AppColors.blue500);
      expect(TaskStatusTheme.accent('RESOLVED'), AppColors.green700);
      expect(TaskStatusTheme.accent('APPROVED'), AppColors.green700);
      expect(TaskStatusTheme.accent('ACCEPTED'), AppColors.green700);
      expect(TaskStatusTheme.accent('REJECTED'), AppColors.red500);
      expect(TaskStatusTheme.accent('REJECTED_BY_STAFF'), AppColors.red500);
      expect(TaskStatusTheme.accent('ADDED_TO_ROUTE'), AppColors.purple600);
      expect(TaskStatusTheme.accent('ROUTED'), AppColors.purple600);
      expect(TaskStatusTheme.accent('PENDING'), AppColors.amber600);
      expect(TaskStatusTheme.accent(null), AppColors.amber600);
    });

    test('formatStatus humanizes status strings', () {
      expect(TaskStatusTheme.formatStatus('IN_PROGRESS'), 'In Progress');
      expect(TaskStatusTheme.formatStatus('RESOLVED'), 'Resolved');
      expect(TaskStatusTheme.formatStatus('APPROVED'), 'Approved');
      expect(TaskStatusTheme.formatStatus('REJECTED'), 'Rejected');
      expect(TaskStatusTheme.formatStatus('REJECTED_BY_STAFF'), 'Rejected by Staff');
      expect(TaskStatusTheme.formatStatus('ADDED_TO_ROUTE'), 'Added to Route');
      expect(TaskStatusTheme.formatStatus('PENDING'), 'Pending');
      expect(TaskStatusTheme.formatStatus(null), 'Unknown');
      expect(TaskStatusTheme.formatStatus(''), 'Unknown');
      expect(TaskStatusTheme.formatStatus('CUSTOM_STATUS_NAME'), 'Custom Status Name');
    });

    test('urgencyColor maps urgency levels properly', () {
      expect(TaskStatusTheme.urgencyColor('HIGH'), AppColors.red500);
      expect(TaskStatusTheme.urgencyColor('Critical'), AppColors.red500);
      expect(TaskStatusTheme.urgencyColor('Medium'), AppColors.amberDark);
      expect(TaskStatusTheme.urgencyColor('Low'), AppColors.green700);
      expect(TaskStatusTheme.urgencyColor(null), AppColors.grey500);
    });

    test('statusIcon returns expected icons', () {
      expect(TaskStatusTheme.statusIcon('IN_PROGRESS'), Icons.pending_actions_rounded);
      expect(TaskStatusTheme.statusIcon('RESOLVED'), Icons.check_circle_rounded);
      expect(TaskStatusTheme.statusIcon('REJECTED'), Icons.cancel_rounded);
      expect(TaskStatusTheme.statusIcon('ADDED_TO_ROUTE'), Icons.alt_route_rounded);
      expect(TaskStatusTheme.statusIcon('PENDING'), Icons.hourglass_top_rounded);
    });
  });
}
