import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class AchievementListSection extends StatelessWidget {
  const AchievementListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events_outlined, color: AppColors.grey900, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Recent Achievements',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAchievementItem(
          title: 'Early Bird',
          subtitle: 'Earned 2 days ago',
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 12),
        _buildAchievementItem(
          title: 'Perfect Week',
          subtitle: 'Earned 1 week ago',
          icon: Icons.star_border,
        ),
        const SizedBox(height: 12),
        _buildAchievementItem(
          title: 'Quick Reporter',
          subtitle: 'Earned 3 days ago',
          icon: Icons.bolt,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.green700, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: AppColors.green700, size: 24),
        ],
      ),
    );
  }
}
