import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/presentation/field_staff/bins/bin_map_page.dart';

class BinDetailsOverlay extends StatelessWidget {
  final BinModel bin;
  final VoidCallback? onUpdateStatus;

  const BinDetailsOverlay({
    super.key,
    required this.bin,
    this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          bin.id,
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
                          color: _getBadgeBgColor(bin.displayStatus),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          bin.displayStatus.label.toUpperCase(),
                          style: AppTypography.captionSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getStatusTextColor(bin.displayStatus),
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
              // Title & Subtitle
              Text(bin.displayCode, style: AppTypography.h2),
              const SizedBox(height: 4),
              Text(
                bin.address,
                style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 24),

              if (bin.hasDiscrepancy) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amberSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.amber600.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.amberDark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A status discrepancy was reported and is visible to admin.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.amberDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Status Large Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: ShapeDecoration(
                  color: _getCardBgColor(bin.displayStatus),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.27, color: _getCardBorderColor(bin.displayStatus)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getCardTextColor(bin.displayStatus),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _getStatusIcon(bin.displayStatus),
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bin.displayStatus.label,
                      style: AppTypography.h1.copyWith(
                        color: _getCardTextColor(bin.displayStatus),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Details List
              _buildDetailRow('Type', bin.displayCategory),
              Divider(color: AppColors.grey100, height: 32),
              _buildDetailRow('Last Checked', bin.timeAgo),
              Divider(color: AppColors.grey100, height: 32),
              _buildDetailRow('Assigned To', bin.assignedToName ?? 'Unassigned'),
              if (bin.fillLevel != null) ...[
                Divider(color: AppColors.grey100, height: 32),
                _buildDetailRow('Fill level', '${bin.fillLevel}%'),
              ],
              const SizedBox(height: 24),

              if (onUpdateStatus != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onUpdateStatus!();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.green700,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bin.needsStatusCheck ? 'Verify Fill Level' : 'Update Status',
                            style: AppTypography.titleSm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (onUpdateStatus != null) const SizedBox(height: 12),

              // Bottom View Map Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BinMapPage(bin: bin),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: AppDecorations.card(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.grey700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View on Map',
                          style: AppTypography.titleSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
        ),
        Text(
          value,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }

  // --- Theme Helpers based on Status ---

  Color _getBadgeBgColor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey100; // Grey
      case BinStatus.full:
        return AppColors.redSurface2; // Light Red
      case BinStatus.half:
        return AppColors.yellow; // Light Yellow
      case BinStatus.empty:
        return AppColors.greenSurface2; // Light Green
    }
  }

  Color _getStatusTextColor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey600; // Dark Grey
      case BinStatus.full:
        return AppColors.redDark; // Dark Red
      case BinStatus.half:
        return AppColors.yellowDark; // Dark Yellow
      case BinStatus.empty:
        return AppColors.greenDark; // Dark Green
    }
  }

  Color _getCardBgColor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey50;
      case BinStatus.full:
        return AppColors.redSurface2;
      case BinStatus.half:
        return AppColors.yellow;
      case BinStatus.empty:
        return AppColors.greenSurface3;
    }
  }

  Color _getCardBorderColor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.grey200;
      case BinStatus.full:
        return AppColors.red100;
      case BinStatus.half:
        return AppColors.yellow400.withValues(alpha: 0.3);
      case BinStatus.empty:
        return AppColors.greenBorder2;
    }
  }

  Color _getCardTextColor(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return AppColors.citizenGrey500;
      case BinStatus.full:
        return AppColors.redDark2;
      case BinStatus.half:
        return AppColors.yellowDark;
      case BinStatus.empty:
        return AppColors.greenDark2;
    }
  }

  IconData _getStatusIcon(BinStatus status) {
    switch (status) {
      case BinStatus.notChecked:
        return Icons.help_outline;
      case BinStatus.full:
        return Icons.sentiment_very_dissatisfied;
      case BinStatus.half:
        return Icons.sentiment_neutral;
      case BinStatus.empty:
        return Icons.sentiment_satisfied_alt;
    }
  }
}
