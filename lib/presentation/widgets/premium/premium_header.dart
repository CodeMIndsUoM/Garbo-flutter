import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<PremiumStatItem> stats;
  final Widget? trailing;

  const PremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.stats = const [],
    this.trailing,
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
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 12,
        24,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h1.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.white90,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: stats
                  .map((stat) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: stat == stats.last ? 0 : 8.0,
                          ),
                          child: _buildStatItem(stat),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(PremiumStatItem stat) {
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
              if (stat.icon != null) ...[
                Icon(stat.icon, color: Colors.white, size: 18),
                const SizedBox(width: 4),
              ],
              Text(
                stat.value,
                style: AppTypography.displaySm.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: AppTypography.caption.copyWith(color: AppColors.white90),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PremiumStatItem {
  final String value;
  final String label;
  final IconData? icon;

  const PremiumStatItem({
    required this.value,
    required this.label,
    this.icon,
  });
}
