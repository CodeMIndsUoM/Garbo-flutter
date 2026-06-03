import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class PerformanceGrid extends StatelessWidget {
  final int totalBins;
  final int pendingBins;
  final int? avgResponseMinutes;

  const PerformanceGrid({
    super.key,
    required this.totalBins,
    required this.pendingBins,
    this.avgResponseMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final int completedBins = totalBins - pendingBins;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Performance", style: AppTypography.titleLg),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildItem(
                    title: '$completedBins',
                    subtitle: 'Bins Checked',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildItem(
                    title: '$totalBins',
                    subtitle: 'Assigned Bins',
                    icon: Icons.map_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildItem(
                    title: avgResponseMinutes == null
                        ? '--'
                        : '${avgResponseMinutes!} mins',
                    subtitle: 'Avg Response',
                    icon: Icons.timer_outlined,
                  ),
                ),
                Expanded(
                  child: _buildItem(
                    title: '--',
                    subtitle: 'Points Today',
                    icon: Icons.bolt,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.green700, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.h3.copyWith(
                color: AppColors.grey900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
        ),
      ],
    );
  }
}
