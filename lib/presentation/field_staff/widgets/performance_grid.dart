import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class PerformanceGrid extends StatelessWidget {
  const PerformanceGrid({super.key});

  @override
  Widget build(BuildContext context) {
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildGridItem(
              title: '6',
              subtitle: 'Bins Reported',
              status: '2 remaining',
              statusColor: AppColors.green700,
              icon: Icons.check_circle_outline,
              themeColor: AppColors.green700,
              bgColor: AppColors.emerald50,
            ),
            _buildGridItem(
              title: '8',
              subtitle: 'Assigned Bins',
              status: 'In your zone',
              statusColor: AppColors.blue600,
              icon: Icons.map_outlined,
              themeColor: AppColors.blue600,
              bgColor: AppColors.blue50,
            ),
            _buildGridItem(
              title: '4 mins',
              subtitle: 'Avg Response',
              status: 'Very quick!',
              statusColor: AppColors.green700,
              icon: Icons.timer_outlined,
              themeColor: AppColors.orange600,
              bgColor: AppColors.orange50,
            ),
            _buildGridItem(
              title: '+145',
              subtitle: 'Points Today',
              status: 'Keep it up!',
              statusColor: AppColors.purple600,
              icon: Icons.bolt,
              themeColor: AppColors.purple600,
              bgColor: AppColors.purple50,
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
    // Approx width for 2 items with padding on 396px screen: (396 - 48 - 12) / 2 = 168
    // Using flexible sizing in parent instead of fixed width
    return Container(
      width: 168,
      height: 142,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.27, color: AppColors.grey100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
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
