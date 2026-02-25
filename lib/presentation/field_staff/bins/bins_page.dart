import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/presentation/field_staff/bins/widgets/bin_card.dart';
import 'package:garbo_swms/presentation/field_staff/bins/widgets/bin_filter_chips.dart';
import 'package:garbo_swms/presentation/field_staff/bins/report_bin_page.dart';
import 'package:garbo_swms/data/sources/api_service.dart';

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
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  // Use empty list initially
  List<BinModel> _bins = [];

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Hardcoded empId for demo (Sasindu)
      final bins = await _apiService.getAssignedBins("3");
      setState(() {
        _bins = bins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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

    // Sort so 'Not Checked' bins appear at the top
    bins.sort((a, b) {
      if (a.status == BinStatus.notChecked && b.status != BinStatus.notChecked) {
        return -1;
      }
      if (a.status != BinStatus.notChecked && b.status == BinStatus.notChecked) {
        return 1;
      }
      return 0; // Maintain natural ordering for the rest
    });

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading bins: $_error', style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _fetchBins, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchBins,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
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
                      ],
                    ),
                  ),
                  _filteredBins.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final bin = _filteredBins[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: BinCard(
                                    bin: bin,
                                    onReport: () => _handleReport(bin),
                                    onUndo: () => _handleUndo(bin),
                                  ),
                                );
                              },
                              childCount: _filteredBins.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
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
                  color: Colors.black38,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 6),
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

  Future<void> _handleReport(BinModel bin) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportBinPage(
          bin: bin,
          empId: "3", // Hardcoded for demo
        ),
      ),
    );

    if (result == true) {
      _fetchBins(); // Refresh list if report was submitted
    }
  }

  Future<void> _handleUndo(BinModel bin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo Report?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text(
          'This will reset the bin status to Not Checked. You can then report it again safely.',
          style: TextStyle(fontFamily: 'Arimo', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Undo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await _apiService.undoBinReport("3", bin.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report for ${bin.id} undone.'),
            backgroundColor: AppColors.green700,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to undo report.'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to undo: $e'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    } finally {
      if (mounted) {
        _fetchBins();
      }
    }
  }
}
