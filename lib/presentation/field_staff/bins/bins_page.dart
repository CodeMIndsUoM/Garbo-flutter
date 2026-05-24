import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';
import 'package:garbo_swms/presentation/field_staff/bins/widgets/bin_card.dart';
import 'package:garbo_swms/presentation/field_staff/bins/widgets/bin_filter_chips.dart';
import 'package:garbo_swms/presentation/field_staff/bins/report_bin_page.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _empId = '';
  bool _didAttachRealtimeListener = false;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _binStatusSocketSubscription;

  // Use empty list initially
  List<BinModel> _bins = [];

  @override
  void initState() {
    super.initState();
    _loadEmpIdAndFetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAttachRealtimeListener) {
      return;
    }
    _didAttachRealtimeListener = true;
    _attachRealtimeBinUpdates(context.read<WebSocketProvider>());
  }

  void _attachRealtimeBinUpdates(WebSocketProvider webSocketProvider) {
    _binStatusSocketSubscription?.cancel();
    _binStatusSocketSubscription = webSocketProvider.messageStream.listen((
      message,
    ) {
      if (message.type != 'BIN_STATUS_UPDATED') {
        return;
      }

      final payload = message.payload;
      if (payload == null) {
        return;
      }

      final assignedToEmpId = _parseInt(payload['assignedToEmpId']);
      final currentEmpId = int.tryParse(_empId);
      if (assignedToEmpId != null &&
          currentEmpId != null &&
          assignedToEmpId != currentEmpId) {
        return;
      }

      _applyRealtimeBinStatus(payload);
    });
  }

  void _applyRealtimeBinStatus(Map<String, dynamic> payload) {
    if (!mounted) {
      return;
    }

    final binId = payload['binId']?.toString();
    if (binId == null || binId.isEmpty) {
      return;
    }

    final status = _parseBinStatus(payload['status']);
    final fillLevel = _parseInt(payload['fillLevel']);
    final lastChecked = _parseDateTime(payload['lastChecked']);
    final isUndo =
        payload['changeType']?.toString().toUpperCase() == 'STATUS_UNDONE' ||
        status == BinStatus.notChecked;

    final index = _bins.indexWhere((bin) => _isSameBin(bin, binId));
    if (index < 0) {
      // If the backend sends a newly assigned/unknown bin, reload once so the
      // local list catches up without requiring a manual refresh.
      _fetchBins();
      return;
    }

    setState(() {
      final current = _bins[index];
      _bins[index] = current.copyWith(
        status: status,
        fillLevel: fillLevel,
        clearFillLevel: isUndo && fillLevel == null,
        lastChecked: lastChecked,
        clearLastChecked: isUndo,
      );
    });
  }

  Future<void> _loadEmpIdAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _empId = prefs.getString('empId') ?? '';
    if (_empId.isEmpty) {
      setState(() {
        _error = 'No employee ID found. Please log in again.';
        _isLoading = false;
      });
      return;
    }
    await _fetchBins();
  }

  @override
  void dispose() {
    _binStatusSocketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchBins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final bins = await _apiService.getAssignedBins();
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
      bins = bins
          .where(
            (b) =>
                b.location.toLowerCase().contains(q) ||
                b.id.toLowerCase().contains(q) ||
                b.address.toLowerCase().contains(q),
          )
          .toList();
    }

    // Sort so 'Not Checked' bins appear at the top
    bins.sort((a, b) {
      if (a.status == BinStatus.notChecked &&
          b.status != BinStatus.notChecked) {
        return -1;
      }
      if (a.status != BinStatus.notChecked &&
          b.status == BinStatus.notChecked) {
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
            Text(
              'Error loading bins: $_error',
              style: AppTypography.bodyMd.copyWith(color: AppColors.red500),
            ),
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
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final bin = _filteredBins[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: BinCard(
                                  bin: bin,
                                  onReport: () => _handleReport(bin),
                                  onUndo: () => _handleUndo(bin),
                                ),
                              );
                            }, childCount: _filteredBins.length),
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
              style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
              decoration: InputDecoration(
                hintText: 'Search bins by location or ID...',
                hintStyle: AppTypography.bodyMd.copyWith(color: Colors.black38),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(bottom: 6),
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
            style: AppTypography.bodyLg.copyWith(
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
        builder: (context) => ReportBinPage(bin: bin, empId: _empId),
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
        content: Text(
          'This will reset the bin status to Not Checked. You can then report it again safely.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMd.copyWith(color: AppColors.grey600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Undo',
              style: AppTypography.buttonMd.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await _apiService.undoBinReport(bin.id);
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

  bool _isSameBin(BinModel bin, String pushedBinId) {
    final normalizedPushId = _normalizeBinId(pushedBinId);
    return _normalizeBinId(bin.id) == normalizedPushId ||
        _normalizeBinId(bin.displayCode) == normalizedPushId;
  }

  String _normalizeBinId(String value) {
    final trimmed = value.trim().toLowerCase();
    final displayCodeMatch = RegExp(r'bin[-_\s]*(\d+)').firstMatch(trimmed);
    if (displayCodeMatch != null) {
      return displayCodeMatch.group(1) ?? trimmed;
    }
    final digitsOnly = RegExp(
      r'\d+',
    ).allMatches(trimmed).map((m) => m.group(0)).join();
    return digitsOnly.isNotEmpty ? digitsOnly : trimmed;
  }

  BinStatus _parseBinStatus(dynamic value) {
    final status = value?.toString();
    if (status == null) return BinStatus.notChecked;
    return BinStatus.values.firstWhere(
      (item) => item.name.toLowerCase() == status.toLowerCase(),
      orElse: () => BinStatus.notChecked,
    );
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  DateTime? _parseDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
