import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/models/bin_model.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/bin_card.dart';
import 'package:garbo_swms/presentation/field_staff/widgets/bin_filter_chips.dart';

/// Bins page shown when the "Bins" tab is selected.
///
/// To integrate with backend:
/// 1. Replace [_bins] with data fetched from your API.
/// 2. Use `BinModel.fromJson()` to parse the response.
/// 3. Call `setState` (or use a state management solution) to update [_bins].
class BinsPage extends StatefulWidget {
  const BinsPage({super.key});

  @override
  State<BinsPage> createState() => _BinsPageState();
}

class _BinsPageState extends State<BinsPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // ──────────────────────────────────────────────
  // DEMO DATA — Replace with API call when backend
  // is ready. Example:
  //
  //   Future<void> _fetchBins() async {
  //     final response = await apiService.getBins();
  //     setState(() {
  //       _bins = response.map(BinModel.fromJson).toList();
  //     });
  //   }
  // ──────────────────────────────────────────────
  final List<BinModel> _bins = BinModel.demoData;

  List<BinModel> get _filteredBins {
    var bins = _bins;

    // Apply status filter
    switch (_selectedFilter) {
      case 'Not Checked':
        bins = bins.where((b) => b.status == BinStatus.notChecked).toList();
        break;
      case 'Full':
        bins = bins.where((b) => b.status == BinStatus.full).toList();
        break;
      case 'Half':
        bins = bins.where((b) => b.status == BinStatus.half).toList();
        break;
      case 'Empty':
        bins = bins.where((b) => b.status == BinStatus.empty).toList();
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      bins = bins.where((b) =>
          b.location.toLowerCase().contains(q) ||
          b.id.toLowerCase().contains(q) ||
          b.address.toLowerCase().contains(q)).toList();
    }

    return bins;
  }

  List<BinFilterItem> get _filterItems => [
        BinFilterItem(label: 'All', count: _bins.length),
        BinFilterItem(
          label: 'Not Checked',
          count: _bins.where((b) => b.status == BinStatus.notChecked).length,
        ),
        BinFilterItem(
          label: 'Full',
          count: _bins.where((b) => b.status == BinStatus.full).length,
        ),
        BinFilterItem(
          label: 'Half',
          count: _bins.where((b) => b.status == BinStatus.half).length,
        ),
        BinFilterItem(
          label: 'Empty',
          count: _bins.where((b) => b.status == BinStatus.empty).length,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: _buildSearchBar(),
        ),
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BinFilterChips(
            filters: _filterItems,
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Bin list
        Expanded(
          child: _filteredBins.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: _filteredBins.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bin = _filteredBins[index];
                    return BinCard(
                      bin: bin,
                      onReport: () => _handleReport(bin),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: AppColors.grey500, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 14,
                color: AppColors.grey900,
              ),
              decoration: const InputDecoration(
                hintText: 'Search bins by location or ID...',
                hintStyle: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'No bins found',
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleReport(BinModel bin) {
    // TODO: Navigate to report screen or show report dialog.
    // When backend is ready, this will call the API to submit a report.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reporting fill level for ${bin.id} - ${bin.location}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green700,
      ),
    );
  }
}
