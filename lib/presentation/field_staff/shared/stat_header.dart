import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/shared/widgets/settings_overlay.dart';

class StatHeader extends StatelessWidget {
  final String title;
  final String userName;
  final int toCheckCount;
  final int dayStreak;
  final String avgResponseLabel;

  const StatHeader({
    super.key,
    this.title = 'Field Staff',
    this.userName = 'Field Staff',
    this.toCheckCount = 0,
    this.dayStreak = 0,
    this.avgResponseLabel = '--',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.grey50),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h1.copyWith(color: AppColors.grey900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hello, $userName!',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const SettingsOverlay(),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu, color: AppColors.grey900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
