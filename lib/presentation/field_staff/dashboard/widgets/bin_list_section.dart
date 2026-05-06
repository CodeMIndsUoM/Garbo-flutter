import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

class BinListSection extends StatelessWidget {
  final List<BinModel> bins;
  final Function(BinModel) onReport;

  const BinListSection({super.key, required this.bins, required this.onReport});

  @override
  Widget build(BuildContext context) {
    // Filter for bins that need checking (notChecked) and take top 3
    final pendingBins = bins
        .where((b) => b.status == BinStatus.notChecked)
        .take(3)
        .toList();

    if (pendingBins.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.delete_outline,
                  color: AppColors.grey900,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('Bins to Check Today', style: AppTypography.titleLg),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${pendingBins.length} PENDING',
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pendingBins.map(
          (bin) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBinItem(bin),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBinItem(BinModel bin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.27, color: AppColors.grey200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bin.id,
                  style: AppTypography.overline.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bin.status.label.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(bin.displayCode, style: AppTypography.titleLg),
          Text(
            bin.address,
            style: AppTypography.caption.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onReport(bin),
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
                  const Icon(
                    Icons.send_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
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
          ),
        ],
      ),
    );
  }
}
