import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

class ProfileStatRow {
  final String label;
  final String value;

  const ProfileStatRow({required this.label, required this.value});
}

/// Performance stats block — same layout as field staff profile.
class ProfileStatsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ProfileStatRow> rows;
  final Widget? trailing;
  final Widget? topWidget;

  const ProfileStatsSection({
    super.key,
    this.title = 'Performance Stats',
    this.icon = Icons.analytics_outlined,
    required this.rows,
    this.trailing,
    this.topWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.grey900, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: AppTypography.titleLg),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (topWidget != null) ...[
            const SizedBox(height: 12),
            topWidget!,
          ],
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSm,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.grey100),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            rows[i].label,
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.grey900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          rows[i].value,
                          style: AppTypography.titleMd.copyWith(
                            color: AppColors.green700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
