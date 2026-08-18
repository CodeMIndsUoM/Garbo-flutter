import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Filter chip item model for Special Tasks page filters.
class TaskFilterItem {
  final String label;
  final int count;

  const TaskFilterItem({required this.label, required this.count});
}

/// Horizontal scrollable filter chips with counts, matching Bins page design.
class TaskFilterChips extends StatelessWidget {
  final List<TaskFilterItem> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TaskFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter.label == selectedFilter;
          final Color chipBgColor = isSelected ? AppColors.green700 : AppColors.surfaceVariant;
          final Color chipTextColor = isSelected ? Colors.white : AppColors.grey600;

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
