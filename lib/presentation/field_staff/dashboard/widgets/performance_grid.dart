import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class PerformanceGrid extends StatelessWidget {
  final int totalBins;
  final int pendingBins;

  const PerformanceGrid({
    super.key,
    required this.totalBins,
    required this.pendingBins,
  });

  @override
  Widget build(BuildContext context) {
    final int completedBins = totalBins - pendingBins;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Performance",
          style: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildGridItem(
                    title: '$completedBins',
                    subtitle: 'Bins Checked',
                    status: '$pendingBins remaining',
                    statusColor: AppColors.green700,
                    icon: Icons.check_circle_outline,
                    themeColor: AppColors.green700,
                    bgColor: AppColors.emerald50,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridItem(
                    title: '$totalBins',
                    subtitle: 'Assigned Bins',
                    status: 'In your zone',
                    statusColor: AppColors.green700,
                    icon: Icons.map_outlined,
                    themeColor: AppColors.green700,
                    bgColor: AppColors.emerald50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGridItem(
                    title: '4 mins',
                    subtitle: 'Avg Response',
                    status: 'Very quick!',
                    statusColor: AppColors.green700,
                    icon: Icons.timer_outlined,
                    themeColor: AppColors.green700,
                    bgColor: AppColors.emerald50,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridItem(
                    title: '+145',
                    subtitle: 'Points Today',
                    status: 'Keep it up!',
                    statusColor: AppColors.green700,
                    icon: Icons.bolt,
                    themeColor: AppColors.green700,
                    bgColor: AppColors.emerald50,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color themeColor,
    required Color bgColor,
  }) {
    // Width is flexible and handled by the Expanded parent
    return Container(
      height: 142,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.27, color: AppColors.grey100),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: themeColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.grey600,
              height: 1.33,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: statusColor,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}
