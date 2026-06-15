import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Search field + filter button used on citizen "My …" list screens.
class CitizenSearchFilterBar extends StatelessWidget {
  const CitizenSearchFilterBar({
    super.key,
    required this.searchController,
    required this.hintText,
    required this.onChanged,
    required this.onFilterTap,
    this.activeFilterCount = 0,
  });

  final TextEditingController searchController;
  final String hintText;
  final VoidCallback onChanged;
  final VoidCallback onFilterTap;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final hasFilters = activeFilterCount > 0;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: AppDecorations.card(),
            child: TextField(
              controller: searchController,
              onChanged: (_) => onChanged(),
              style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
              decoration: AppDecorations.searchInput(
                hintText: hintText,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.grey500,
                ),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          searchController.clear();
                          onChanged();
                        },
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: hasFilters ? AppColors.emerald600 : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onFilterTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasFilters ? AppColors.emerald600 : AppColors.grey300,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      Icons.tune_rounded,
                      color: hasFilters ? Colors.white : AppColors.grey700,
                      size: 20,
                    ),
                  ),
                  if (hasFilters)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$activeFilterCount',
                          style: AppTypography.captionSm.copyWith(
                            color: AppColors.emerald600,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
