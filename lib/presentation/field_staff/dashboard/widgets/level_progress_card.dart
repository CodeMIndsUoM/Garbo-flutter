import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';

class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 1.27),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple50, AppColors.blue50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.27, color: AppColors.purple200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.purple600, AppColors.blue500],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level 8',
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey900,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        'Monitor Expert',
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: AppColors.grey600,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '1847 pts',
                    style: const TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purple600,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '153 to Level 9',
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
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.8, // 1847 / 2000 approx
              backgroundColor: AppColors.white20, // Should be white/60
              color: null,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple600), // Gradient not directly supported in LPI, using solid color for now
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }
}
