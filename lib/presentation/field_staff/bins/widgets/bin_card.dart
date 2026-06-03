import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/presentation/field_staff/bins/widgets/bin_details_overlay.dart';

/// A single bin card matching the Figma design.
///
/// Features:
/// - Colored left border accent based on status
/// - Category badge (green pill)
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
          builder: (context) => BinDetailsOverlay(bin: bin),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSm,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              color: _statusLineColor,
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
                  if (bin.status == BinStatus.notChecked) ...[
                    const SizedBox(height: 12),
                    _buildReportButton(),
                  ] else ...[
                    const SizedBox(height: 12),
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
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            bin.id,
            style: AppTypography.overline.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.grey700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.grey600,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            bin.displayCategory,
            style: AppTypography.overline.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        // Status label pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bin.status == BinStatus.notChecked
                ? Colors.transparent
                : _statusTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: bin.status == BinStatus.notChecked
                  ? Colors.transparent
                  : _statusTextColor.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Text(
            bin.status.label,
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              color: _statusTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportButton() {
    return GestureDetector(
      onTap: onReport,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.green700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
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
              'Report Fill Level',
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
    return GestureDetector(
      onTap: onUndo,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowXs,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.undo, color: AppColors.grey700, size: 16),
            const SizedBox(width: 8),
            Text(
              'Undo Report',
              style: AppTypography.titleSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status-based colors ──

  Color get _statusLineColor {
    switch (bin.status) {
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

  Color get _statusTextColor {
    switch (bin.status) {
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
