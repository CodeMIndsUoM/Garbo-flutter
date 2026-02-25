import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

/// A single bin card matching the Figma design.
///
/// Features:
/// - Colored left border accent based on status
/// - Category badge (green pill)
/// - Status label (colored text, top-right)
/// - Location, address, time-ago
/// - "Report Fill Level" button for unchecked bins
class BinCard extends StatelessWidget {
  final BinModel bin;
  final VoidCallback? onReport;
  final VoidCallback? onUndo;

  const BinCard({
    super.key,
    required this.bin,
    this.onReport,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1, color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(),
            const SizedBox(height: 8),
            Text(
              bin.location,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
                height: 1.5,
              ),
            ),
            Text(
              bin.address,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.grey600,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  bin.timeAgo,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.grey500,
                    height: 1.33,
                  ),
                ),
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
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 10,
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
            bin.category.label,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 10,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Text(
            bin.status.label,
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
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
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.send_outlined, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Report Fill Level',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.43,
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
          border: Border.all(color: AppColors.grey200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.undo, color: AppColors.grey700, size: 16),
            SizedBox(width: 8),
            Text(
              'Undo Report',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.grey700,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status-based colors ──

  Color get _cardBgColor {
    switch (bin.status) {
      case BinStatus.notChecked:
        return Colors.white;
      case BinStatus.full:
        return const Color(0xFFFEF2F2); // light red
      case BinStatus.half:
        return const Color(0xFFFFFBEB); // light yellow/cream
      case BinStatus.empty:
        return const Color(0xFFECFDF5); // light green
    }
  }

  Color get _borderColor {
    switch (bin.status) {
      case BinStatus.notChecked:
        return AppColors.grey200;
      case BinStatus.full:
        return const Color(0xFFFECACA); // red border
      case BinStatus.half:
        return const Color(0xFFFDE68A); // amber border
      case BinStatus.empty:
        return const Color(0xFFA7F3D0); // green border
    }
  }



  Color get _statusTextColor {
    switch (bin.status) {
      case BinStatus.notChecked:
        return AppColors.grey500;
      case BinStatus.full:
        return AppColors.red500;
      case BinStatus.half:
        return AppColors.orange500;
      case BinStatus.empty:
        return AppColors.green700;
    }
  }
}
