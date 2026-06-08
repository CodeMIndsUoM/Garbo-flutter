import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text("Today's Performance", style: AppTypography.titleLg),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            children: [
              _buildCardItem(
                title: '$completedBins',
                subtitle: 'Bins Checked',
                icon: Icons.delete_sweep_outlined,
              ),
              const SizedBox(width: 12),
              _buildCardItem(
                title: '$totalBins',
                subtitle: 'Assigned Bins',
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(width: 12),
              _buildCardItem(
                title: avgResponseMinutes == null
                    ? '--'
                    : '${avgResponseMinutes!} mins',
                subtitle: 'Avg Response',
                icon: Icons.speed_outlined,
              ),
              const SizedBox(width: 12),
              _buildCardItem(
                title: '--',
                subtitle: 'Points Today',
                icon: Icons.emoji_events_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: AppDecorations.metricIconBox(),
            child: Icon(icon, color: AppColors.green700, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.h2.copyWith(
              color: AppColors.grey900,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
