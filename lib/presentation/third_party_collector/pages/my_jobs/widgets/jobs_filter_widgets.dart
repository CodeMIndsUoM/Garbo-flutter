import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/app_theme_sync.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/offer_details_sheet.dart';

/// The sub-tab filter bar (Awaiting / Accepted / Rejected pills) with
/// the advanced-filter icon button.
class JobsFilterBar extends StatelessWidget {
  final List<(OfferStatus, String)> offerTabs;
  final List<CollectionOfferModel> Function(OfferStatus) offersByStatus;
  final int activeFilterCount;
  final VoidCallback onOpenFilters;
  final bool showFilterButton;

  const JobsFilterBar({
    super.key,
    required this.offerTabs,
    required this.offersByStatus,
    required this.activeFilterCount,
    required this.onOpenFilters,
    this.showFilterButton = true,
  });

  @override
  Widget build(BuildContext context) {
    syncAppColorsFromContext(context);

    final controller = DefaultTabController.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  return Row(
                    children: List.generate(offerTabs.length, (i) {
                      final (status, label) = offerTabs[i];
                      final count = offersByStatus(status).length;
                      final selected = controller.index == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => controller.animateTo(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.green700
                                  : AppColors.grey100,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: AppTypography.labelMd.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.grey600,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : AppColors.grey200,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: AppTypography.captionSm.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : AppColors.grey600,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          if (showFilterButton) ...[
            const SizedBox(width: 8),
            _buildFilterIconButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterIconButton() {
    final hasFilters = activeFilterCount > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: hasFilters ? AppColors.green700 : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFilters ? AppColors.green700 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: hasFilters
            ? [
                BoxShadow(
                  color: AppColors.green700.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.shadowSm,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onOpenFilters,
          borderRadius: BorderRadius.circular(12),
          splashColor: hasFilters
              ? Colors.white.withValues(alpha: 0.2)
              : AppColors.emerald50,
          child: SizedBox(
            width: 44,
            height: 44,
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
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.green700,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Active filter chips rail shown below the filter bar.
class JobsActiveFiltersRail extends StatelessWidget {
  final String searchQuery;
  final Set<String> selectedWasteTypes;
  final int? createdWithinDays;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onRemoveWasteType;
  final VoidCallback onClearDays;
  final VoidCallback onClearAll;

  const JobsActiveFiltersRail({
    super.key,
    required this.searchQuery,
    required this.selectedWasteTypes,
    required this.createdWithinDays,
    required this.onClearSearch,
    required this.onRemoveWasteType,
    required this.onClearDays,
    required this.onClearAll,
  });

  int get _activeFilterCount {
    var count = 0;
    if (selectedWasteTypes.isNotEmpty) count++;
    if (searchQuery.trim().isNotEmpty) count++;
    if (createdWithinDays != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_activeFilterCount == 0) return const SizedBox.shrink();

    final chips = <Widget>[];

    if (searchQuery.trim().isNotEmpty) {
      chips.add(
        _activeFilterChip(
          icon: Icons.search_rounded,
          label: '"${searchQuery.trim()}"',
          onRemove: onClearSearch,
        ),
      );
    }

    for (final type in selectedWasteTypes) {
      chips.add(
        _activeFilterChip(
          icon: Icons.category_outlined,
          label: type.replaceAll('_', ' '),
          onRemove: () => onRemoveWasteType(type),
        ),
      );
    }

    if (createdWithinDays != null) {
      final daysLabel = switch (createdWithinDays!) {
        1 => 'Last 24h',
        7 => 'Last 7d',
        30 => 'Last 30d',
        _ => 'Last ${createdWithinDays}d',
      };
      chips.add(
        _activeFilterChip(
          icon: Icons.access_time_rounded,
          label: daysLabel,
          onRemove: onClearDays,
        ),
      );
    }

    chips.add(
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: TextButton(
          onPressed: onClearAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Clear all',
            style: AppTypography.captionSm.copyWith(
              color: AppColors.green800,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              chips[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _activeFilterChip({
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
              Icon(icon, color: AppColors.green800, size: 13),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSm.copyWith(
                    color: AppColors.green800,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green700,
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
}

/// Bottom bar that appears on the Rejected tab with a "Clear all" action.
class ClearRejectedBar extends StatelessWidget {
  final List<CollectionOfferModel> Function(OfferStatus) offersByStatus;
  final bool clearing;
  final VoidCallback onClear;

  const ClearRejectedBar({
    super.key,
    required this.offersByStatus,
    required this.clearing,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final rejectedCount = offersByStatus(OfferStatus.rejected).length;
        final visible = controller.index == 2 && rejectedCount > 0;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: visible
              ? Container(
                  key: const ValueKey('clear-rejected-bar'),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.grey100, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowSm,
                        offset: Offset(0, -2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$rejectedCount rejected offer${rejectedCount == 1 ? '' : 's'}',
                                style: AppTypography.titleSm.copyWith(
                                  color: AppColors.grey900,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Clean up to keep this list focused',
                                style: AppTypography.captionSm.copyWith(
                                  color: AppColors.grey500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildClearAction(),
                      ],
                    ),
                  ),
                )
              : const SizedBox(
                  key: ValueKey('clear-rejected-hidden'),
                  width: double.infinity,
                ),
        );
      },
    );
  }

  Widget _buildClearAction() {
    return Material(
      color: clearing ? AppColors.grey100 : AppColors.green700,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: clearing ? null : onClear,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (clearing)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.green700,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              const SizedBox(width: 6),
              Text(
                clearing ? 'Clearing...' : 'Clear all',
                style: AppTypography.buttonMd.copyWith(
                  color: clearing ? AppColors.grey500 : Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state for the offers list.
class EmptyOffers extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const EmptyOffers({
    super.key,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: hasActiveFilters ? AppColors.emerald50 : AppColors.grey100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              hasActiveFilters
                  ? Icons.search_off_rounded
                  : Icons.work_off_outlined,
              color: hasActiveFilters ? AppColors.green700 : AppColors.grey400,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasActiveFilters ? 'No matches' : 'No offers found',
            style: AppTypography.titleMd,
          ),
          const SizedBox(height: 4),
          Text(
            hasActiveFilters
                ? 'Try adjusting or clearing your filters'
                : 'Browse requests to send new offers',
            style: AppTypography.bodySm,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onClearFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green800,
                side: BorderSide(color: AppColors.green700, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state for the active jobs list.
class EmptyActiveJobs extends StatelessWidget {
  const EmptyActiveJobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.playlist_add_check_rounded,
              color: AppColors.grey400,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text('No active jobs', style: AppTypography.titleMd),
          const SizedBox(height: 4),
          Text('Accepted offers will appear here', style: AppTypography.bodySm),
        ],
      ),
    );
  }
}
