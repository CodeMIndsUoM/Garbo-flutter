import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/citizen/pages/request/utils/request_constants.dart';

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
    final activeCount = _activeFilterCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    hintText: 'Search requests, addresses, #id',
                    prefixIcon: const Icon(
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
            _buildFilterIconButton(context, activeCount),
          ],
        ),
        if (activeCount > 0) ...[
          const SizedBox(height: 10),
          _buildActiveFilterRail(),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFilterIconButton(BuildContext context, int activeCount) {
    final hasFilters = activeCount > 0;
    return Material(
      color: hasFilters ? AppColors.emerald600 : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openFilterSheet(context),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$activeCount',
                      style: AppTypography.overline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
      backgroundColor: Colors.white,
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
                            ChoiceChip(
                              label: Text(label),
                              selected: localStatus == value,
                              onSelected: (_) =>
                                  setSheetState(() => localStatus = value),
                              selectedColor: AppColors.emerald600,
                              labelStyle: AppTypography.labelSm.copyWith(
                                color: localStatus == value
                                    ? Colors.white
                                    : AppColors.grey700,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: localStatus == value
                                    ? AppColors.emerald600
                                    : AppColors.grey300,
                              ),
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
                            ChoiceChip(
                              label: const Text('All types'),
                              selected: localWasteType == 'ALL',
                              onSelected: (_) => setSheetState(
                                () => localWasteType = 'ALL',
                              ),
                              selectedColor: AppColors.emerald600,
                              labelStyle: AppTypography.labelSm.copyWith(
                                color: localWasteType == 'ALL'
                                    ? Colors.white
                                    : AppColors.grey700,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: localWasteType == 'ALL'
                                    ? AppColors.emerald600
                                    : AppColors.grey300,
                              ),
                            ),
                            for (final type in wasteTypes)
                              ChoiceChip(
                                label: Text(type.replaceAll('_', ' ')),
                                selected: localWasteType == type,
                                onSelected: (_) => setSheetState(
                                  () => localWasteType = type,
                                ),
                                selectedColor: AppColors.emerald600,
                                labelStyle: AppTypography.labelSm.copyWith(
                                  color: localWasteType == type
                                      ? Colors.white
                                      : AppColors.grey700,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: localWasteType == type
                                      ? AppColors.emerald600
                                      : AppColors.grey300,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Apply Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
