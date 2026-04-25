import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class ProfileAchievementList extends StatelessWidget {
  const ProfileAchievementList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.stars_outlined, color: AppColors.grey900, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Achievements',
                  style: TextStyle(
                    color: AppColors.grey900,
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: ShapeDecoration(
                color: AppColors.yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '3/6',
                style: TextStyle(
                  color: AppColors.yellowDark,
                  fontSize: 11,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAchievementCard(
          title: 'Early Bird',
          description: 'Checked bins before 8 AM',
          earnedText: 'Earned 2 days ago',
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 12),
        _buildAchievementCard(
          title: 'Perfect Week',
          description: 'Checked all bins for 7 days',
          earnedText: 'Earned 1 week ago',
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String description,
    required String earnedText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.emerald50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.green700, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.grey900,
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.green700, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.green700, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      earnedText,
                      style: const TextStyle(
                        color: AppColors.green700,
                        fontSize: 11,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
