import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Pill-shaped filter chip matching primary buttons (e.g. Next).
class CitizenFilterChip extends StatelessWidget {
  const CitizenFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.emerald600,
      labelStyle: AppTypography.labelSm.copyWith(
        color: selected ? Colors.white : AppColors.grey700,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.surface,
      shape: const StadiumBorder(),
      side: BorderSide(
        color: selected ? AppColors.emerald600 : AppColors.grey300,
      ),
    );
  }
}
