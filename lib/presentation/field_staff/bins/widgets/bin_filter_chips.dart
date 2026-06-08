import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Filter chip model for Bins page filters.
class BinFilterItem {
  final String label;
  final int count;

  const BinFilterItem({required this.label, required this.count});
}

/// Horizontal scrollable filter chips with counts.
class BinFilterChips extends StatelessWidget {
  final List<BinFilterItem> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const BinFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter.label == selectedFilter;
          Color chipBgColor = AppColors.grey50;
          Color chipTextColor = AppColors.grey600;

          if (isSelected) {
            chipBgColor = AppColors.green700;
            chipTextColor = Colors.white;
          } else {
            chipBgColor = AppColors.grey100;
            chipTextColor = AppColors.grey600;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter.label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isSelected ? '${filter.label} (${filter.count})' : filter.label,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: chipTextColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
