import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class AchievementListSection extends StatelessWidget {
  const AchievementListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: AppColors.grey900,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('Recent Achievements', style: AppTypography.titleLg),
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
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: AppDecorations.metricIconBox(),
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
                  style: AppTypography.titleSm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.green700,
            size: 24,
          ),
        ],
      ),
    );
  }
}
