import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Toggle tabs for "My Offers" and "Active" views.
class JobsTabs extends StatelessWidget {
  final bool showOffers;
  final int offersCount;
  final int activeCount;
  final VoidCallback onOffersTap;
  final VoidCallback onActiveTap;

  const JobsTabs({
    super.key,
    required this.showOffers,
    required this.offersCount,
    required this.activeCount,
    required this.onOffersTap,
    required this.onActiveTap,
  });

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              label: 'My Offers',
              count: offersCount,
              selected: showOffers,
              onTap: onOffersTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem(
              label: 'Active',
              count: activeCount,
              selected: !showOffers,
              onTap: onActiveTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.green700 : AppColors.grey100,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          '$label ($count)',
          style: AppTypography.labelMd.copyWith(
            color: selected ? Colors.white : AppColors.grey600,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
