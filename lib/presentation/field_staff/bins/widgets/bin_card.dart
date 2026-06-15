import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/presentation/field_staff/bins/widgets/bin_details_overlay.dart';

/// A single bin card matching the Figma design.
///
/// Features:
/// - Colored left border accent based on status
/// - Category badge (muted blue pill)
/// - Status label (colored text, top-right)
/// - Bin code, address, time-ago
/// - "Report Fill Level" button for unchecked bins
class BinCard extends StatelessWidget {
  final BinModel bin;
  final VoidCallback? onReport;
  final VoidCallback? onUndo;

  const BinCard({super.key, required this.bin, this.onReport, this.onUndo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BinDetailsOverlay(bin: bin, onUpdateStatus: onReport),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppDecorations.card().copyWith(
          border: bin.hasDiscrepancy
              ? Border.all(color: AppColors.amber600.withValues(alpha: 0.45), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              color: _statusLineColorFor(bin.displayStatus),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(),
                  const SizedBox(height: 8),
                  Text(bin.displayCode, style: AppTypography.titleLg),
                  Text(
                    bin.address,
                    style: AppTypography.caption.copyWith(color: AppColors.grey600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text(bin.timeAgo, style: AppTypography.caption),
                    ],
                  ),
                  if (bin.hasDiscrepancy) ...[
                    const SizedBox(height: 8),
                    _buildDiscrepancyBadge(),
                  ],
                  const SizedBox(height: 12),
                  _buildUpdateButton(),
                  if (bin.status != BinStatus.notChecked) ...[
                    const SizedBox(height: 8),
                    _buildUndoButton(),
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
    return Row(
      children: [
        // Bin ID badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.chipFill,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            bin.id,
            style: AppTypography.overline.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.chipText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.grey300, width: 1),
          ),
          child: Text(
            bin.displayCategory,
            style: AppTypography.overline.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.blue500,
            ),
          ),
        ),
        const Spacer(),
        // Status label pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bin.displayStatus == BinStatus.notChecked
                ? Colors.transparent
                : _statusTextColorFor(bin.displayStatus).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: bin.displayStatus == BinStatus.notChecked
                  ? Colors.transparent
                  : _statusTextColorFor(bin.displayStatus).withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Text(
            bin.displayStatus.label,
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              color: _statusTextColorFor(bin.displayStatus),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscrepancyBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amberSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amber600.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.amberDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Status discrepancy flagged for admin',
              style: AppTypography.caption.copyWith(
                color: AppColors.amberDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    final label = switch (bin.status) {
      BinStatus.notChecked => 'Report Fill Level',
      BinStatus.empty => 'Verify Fill Level',
      _ => 'Update Status',
    };

    return GestureDetector(
      onTap: onReport,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.green700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSm,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUndoButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onUndo,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.undo_rounded, color: AppColors.grey700, size: 18),
              const SizedBox(width: 6),
              Text(
                'Undo report',
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status-based colors ──

  Color _statusLineColorFor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey300;
      case BinStatus.full:
        return AppColors.red500;
      case BinStatus.half:
        return AppColors.yellow400;
      case BinStatus.empty:
        return AppColors.green700;
    }
  }

  Color _statusTextColorFor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey500;
      case BinStatus.full:
        return AppColors.red500;
      case BinStatus.half:
        return AppColors.yellowDark;
      case BinStatus.empty:
        return AppColors.green700;
    }
  }
}
