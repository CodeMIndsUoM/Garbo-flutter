import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/task_status_theme.dart';

class TaskDetailsOverlay extends StatelessWidget {
  final ComplaintModel task;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const TaskDetailsOverlay({
    super.key,
    required this.task,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    final isInProgress = status == 'IN_PROGRESS';
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag handle indicator
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Badges & Close Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // ID Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: AppColors.grey100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                task.displayId,
                                style: AppTypography.captionSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: ShapeDecoration(
                                color: TaskStatusTheme.surface(status),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                TaskStatusTheme.formatStatus(status).toUpperCase(),
                                style: AppTypography.captionSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: TaskStatusTheme.text(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.cancel_outlined,
                            color: AppColors.grey900,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title & Location
                    Text(task.displayTitle, style: AppTypography.h2),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.displayLocation,
                            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Large Status Preview Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: ShapeDecoration(
                        color: TaskStatusTheme.cardBackground(status),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.2, color: TaskStatusTheme.cardBorder(status)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: TaskStatusTheme.cardText(status),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              TaskStatusTheme.statusIcon(status),
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            TaskStatusTheme.formatStatus(status),
                            style: AppTypography.h3.copyWith(
                              color: TaskStatusTheme.cardText(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Citizen Photo Attachment if any
                    if (task.imageUrl != null && task.imageUrl!.trim().isNotEmpty) ...[
                      Text('Attached Photo', style: AppTypography.titleSm),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          task.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Unable to load image',
                              style: AppTypography.caption.copyWith(color: AppColors.grey500),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Details List
                    _buildDetailRow('Issue Type', task.displayIssueType),
                    Divider(color: AppColors.grey100, height: 28),
                    _buildDetailRow('Waste Type', task.wasteType ?? 'N/A'),
                    Divider(color: AppColors.grey100, height: 28),
                    _buildDetailRow('Urgency', task.displayUrgency,
                        customValueColor: TaskStatusTheme.urgencyColor(task.urgency)),
                    Divider(color: AppColors.grey100, height: 28),
                    _buildDetailRow('Reported', task.timeAgo),
                    if (task.council != null && task.council!.isNotEmpty) ...[
                      Divider(color: AppColors.grey100, height: 28),
                      _buildDetailRow('Council', task.council!),
                    ],
                    if (task.description != null && task.description!.trim().isNotEmpty) ...[
                      Divider(color: AppColors.grey100, height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Citizen Description',
                            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.description!,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
                          ),
                        ],
                      ),
                    ],

                    if (task.fieldStaffNote != null && task.fieldStaffNote!.trim().isNotEmpty) ...[
                      Divider(color: AppColors.grey100, height: 28),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff Verification Note',
                            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.fieldStaffNote!,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action Buttons if IN_PROGRESS
                    if (isInProgress) ...[
                      Row(
                        children: [
                          if (onReject != null)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onReject!();
                                },
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.red50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.red100, width: 1.2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cancel_outlined, color: AppColors.red500, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Reject',
                                        style: AppTypography.titleSm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.red500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (onReject != null && onApprove != null)
                            const SizedBox(width: 12),
                          if (onApprove != null)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onApprove!();
                                },
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.green700,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadowSm,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Approve',
                                        style: AppTypography.titleSm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? customValueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: customValueColor ?? AppColors.grey900,
            ),
          ),
        ),
      ],
    );
  }
}
