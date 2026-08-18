import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/task_status_theme.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/widgets/task_details_overlay.dart';

/// A single Special Task card matching the Figma & Bins page design language.
///
/// Features:
/// - Top 4px colored status accent bar for clear status indication
/// - ID badge pill & Category/Waste pill
/// - Status pill on the top-right
/// - Bold task title, location, relative time & urgency
/// - Subtle description preview
/// - Quick Approve / Reject buttons for in-progress tasks
/// - Zero overflow on all screen sizes
class TaskCard extends StatelessWidget {
  final ComplaintModel task;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const TaskCard({
    super.key,
    required this.task,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = task.status;
    final isInProgress = status == 'IN_PROGRESS';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailsOverlay(
            task: task,
            onApprove: onApprove,
            onReject: onReject,
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colored status accent bar
            Container(
              height: 4,
              width: double.infinity,
              color: TaskStatusTheme.accent(status),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(),
                  const SizedBox(height: 10),
                  Text(
                    task.displayTitle,
                    style: AppTypography.titleLg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.displayLocation,
                          style: AppTypography.caption.copyWith(color: AppColors.grey600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text(task.timeAgo, style: AppTypography.caption),
                      if (task.urgency != null && task.urgency!.trim().isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('•', style: AppTypography.caption),
                        ),
                        Text(
                          'Urgency: ${task.displayUrgency}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.grey700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (task.description != null && task.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDescriptionSnippet(),
                  ],
                  if (isInProgress) ...[
                    const SizedBox(height: 14),
                    _buildActionButtons(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    final category = _resolveCategory();

    return Row(
      children: [
        // Task ID badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.chipFill,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            task.displayId,
            style: AppTypography.overline.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.chipText,
            ),
          ),
        ),
        if (category.isNotEmpty) ...[
          const SizedBox(width: 6),
          // Category pill (e.g. Recyclables, Organic, General)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.grey300, width: 1),
            ),
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.overline.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.blue500,
              ),
            ),
          ),
        ],
        const Spacer(),
        // Status pill on the right
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: TaskStatusTheme.surface(task.status),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TaskStatusTheme.badgeBorder(task.status),
              width: 1.2,
            ),
          ),
          child: Text(
            TaskStatusTheme.formatStatus(task.status),
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              color: TaskStatusTheme.text(task.status),
            ),
          ),
        ),
      ],
    );
  }

  String _resolveCategory() {
    if (task.wasteType != null && task.wasteType!.trim().isNotEmpty) {
      return task.wasteType!.trim();
    }
    return '';
  }

  Widget _buildDescriptionSnippet() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        task.description!,
        style: AppTypography.caption.copyWith(color: AppColors.grey700),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onReject != null)
          Expanded(
            child: GestureDetector(
              onTap: onReject,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.red500.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, color: AppColors.red500, size: 16),
                    const SizedBox(width: 4),
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
          const SizedBox(width: 10),
        if (onApprove != null)
          Expanded(
            child: GestureDetector(
              onTap: onApprove,
              child: Container(
                height: 40,
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
                    const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
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
    );
  }
}
