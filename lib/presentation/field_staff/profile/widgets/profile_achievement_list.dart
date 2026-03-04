import 'package:flutter/material.dart';

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
                const Icon(Icons.stars_outlined, color: Color(0xFF101727), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Achievements',
                  style: TextStyle(
                    color: Color(0xFF101727),
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
                color: const Color(0xFFFEF9C2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '3/6',
                style: TextStyle(
                  color: Color(0xFFA65F00),
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
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFBE8), Color(0xFFFFF7EC)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.27, color: Color(0xFFFEEF85)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFEF9C1), Color(0xFFFFECD4)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(icon, color: const Color(0xFFA65F00), size: 28),
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
                        color: Color(0xFF101727),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Color(0xFF00A63E), size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF495565),
                    fontSize: 12,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFF00A63E), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      earnedText,
                      style: const TextStyle(
                        color: Color(0xFF00A63E),
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
