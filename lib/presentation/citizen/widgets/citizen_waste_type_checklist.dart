import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_constants.dart';

class CitizenWasteTypeChecklist extends StatelessWidget {
  const CitizenWasteTypeChecklist({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What needs to be collected? *',
          style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Select one or more waste types',
          style: AppTypography.bodySm.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 12),
        ...wasteTypeItems.map((item) {
          final checked = selected.contains(item);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: checked ? AppColors.greenSurface2 : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final next = Set<String>.from(selected);
                  if (checked) {
                    next.remove(item);
                  } else {
                    next.add(item);
                  }
                  onChanged(next);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: checked
                          ? AppColors.green700.withValues(alpha: 0.45)
                          : AppColors.grey200,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        checked
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: checked ? AppColors.green700 : AppColors.grey500,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.grey900,
                            fontWeight:
                                checked ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
