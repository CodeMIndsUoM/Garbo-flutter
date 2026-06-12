import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_constants.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_filter_chip.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_search_filter_bar.dart';

/// Search bar, filter icon, active-filter rail, and the filter bottom sheet.
class RequestsFilterBar extends StatelessWidget {
  final String statusFilter;
  final String wasteTypeFilter;
  final TextEditingController searchController;
  final List<String> availableWasteTypes;
  final ValueChanged<String> onStatusFilterChanged;
  final ValueChanged<String> onWasteTypeFilterChanged;
  final VoidCallback onChanged;

  const RequestsFilterBar({
    super.key,
    required this.statusFilter,
    required this.wasteTypeFilter,
    required this.searchController,
    required this.availableWasteTypes,
    required this.onStatusFilterChanged,
    required this.onWasteTypeFilterChanged,
    required this.onChanged,
  });

  int get _activeFilterCount {
    var n = 0;
    if (statusFilter != 'ALL') n++;
    if (wasteTypeFilter != 'ALL') n++;
    if (searchController.text.trim().isNotEmpty) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final activeCount = _activeFilterCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CitizenSearchFilterBar(
          searchController: searchController,
          hintText: 'Search requests, addresses, #id',
          onChanged: onChanged,
          onFilterTap: () => _openFilterSheet(context),
          activeFilterCount: activeCount,
        ),
        if (activeCount > 0) ...[
          const SizedBox(height: 10),
          _buildActiveFilterRail(),
        ],
      ],
    );
  }

  Widget _buildActiveFilterRail() {
    final chips = <Widget>[];

    if (statusFilter != 'ALL') {
      final label = statusFilterOptions
          .firstWhere((o) => o.$1 == statusFilter)
          .$2;
      chips.add(
        _buildRailChip(
          icon: Icons.flag_outlined,
          label: label,
          onRemove: () => onStatusFilterChanged('ALL'),
        ),
      );
    }
    if (wasteTypeFilter != 'ALL') {
      chips.add(
        _buildRailChip(
          icon: Icons.category_outlined,
          label: wasteTypeFilter.replaceAll('_', ' '),
          onRemove: () => onWasteTypeFilterChanged('ALL'),
        ),
      );
    }
    final searchText = searchController.text.trim();
    if (searchText.isNotEmpty) {
      chips.add(
        _buildRailChip(
          icon: Icons.search_rounded,
          label: '"$searchText"',
          onRemove: () {
            searchController.clear();
            onChanged();
          },
        ),
      );
    }
    chips.add(
      TextButton(
        onPressed: () {
          searchController.clear();
          onStatusFilterChanged('ALL');
          onWasteTypeFilterChanged('ALL');
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppColors.emerald700,
        ),
        child: const Text(
          'Clear all',
        ),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }

  Widget _buildRailChip({
    required IconData icon,
    required String label,
    required VoidCallback onRemove,
  }) {
    return Material(
      color: AppColors.emerald50,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.emerald700, size: 13),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.emerald700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.emerald600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final wasteTypes = availableWasteTypes;
    var localStatus = statusFilter;
    var localWasteType = wasteTypeFilter;

    final shouldApply = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text('Filters', style: AppTypography.titleLg),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                localStatus = 'ALL';
                                localWasteType = 'ALL';
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Status', style: AppTypography.labelMd),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (value, label) in statusFilterOptions)
                            CitizenFilterChip(
                              label: label,
                              selected: localStatus == value,
                              onSelected: (_) =>
                                  setSheetState(() => localStatus = value),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Waste Type', style: AppTypography.labelMd),
                      const SizedBox(height: 8),
                      if (wasteTypes.isEmpty)
                        Text(
                          'No waste types to filter yet',
                          style: AppTypography.captionSm,
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            CitizenFilterChip(
                              label: 'All types',
                              selected: localWasteType == 'ALL',
                              onSelected: (_) => setSheetState(
                                () => localWasteType = 'ALL',
                              ),
                            ),
                            for (final type in wasteTypes)
                              CitizenFilterChip(
                                label: type.replaceAll('_', ' '),
                                selected: localWasteType == type,
                                onSelected: (_) => setSheetState(
                                  () => localWasteType = type,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Apply Filters'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (shouldApply != true) return;
    onStatusFilterChanged(localStatus);
    onWasteTypeFilterChanged(localWasteType);
  }
}
