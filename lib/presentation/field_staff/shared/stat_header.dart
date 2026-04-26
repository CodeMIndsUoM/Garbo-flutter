import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/shared/widgets/settings_overlay.dart';

class StatHeader extends StatelessWidget {
  final String userName;
  final int toCheckCount;
  final int dayStreak;
  final String avgResponseLabel;

  const StatHeader({
    super.key,
    this.userName = 'Field Staff',
    this.toCheckCount = 0,
    this.dayStreak = 0,
    this.avgResponseLabel = '--',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.green700,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSm,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
                  Text('Field Monitor', style: AppTypography.h1.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Hello, $userName!', style: AppTypography.bodyMd.copyWith(color: AppColors.white90)),
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
                    color: AppColors.white20,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              Expanded(child: _buildStatItem('$toCheckCount', 'To Check')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  avgResponseLabel,
                  'Avg Response',
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  '$dayStreak',
                  'Day Streak',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {IconData? icon}) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white20,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 4),
              ],
              Text(value, style: AppTypography.displaySm.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.white90)),
        ],
      ),
    );
  }
}
