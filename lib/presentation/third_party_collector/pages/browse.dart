import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/send_offer_sheet.dart';

class ThirdPartyBrowsePage extends StatefulWidget {
  const ThirdPartyBrowsePage({super.key});

  @override
  State<ThirdPartyBrowsePage> createState() => _ThirdPartyBrowsePageState();
}

class _ThirdPartyBrowsePageState extends State<ThirdPartyBrowsePage> {
  final ApiService _apiService = ApiService();

  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _loading = false;
  bool _submittingOffer = false;
  String? _collectorId;
  List<CollectionRequestModel> _allRequests = const [];

  static const List<String> _filters = [
    'All',
    'Plastic',
    'Organic',
    'E-Waste',
    'Paper',
    'Metal',
    'Glass',
    'Textile',
    'Mixed',
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final collectorId = await _apiService.getStoredEmpId();
    if (!mounted) return;
    setState(() => _collectorId = collectorId);
    await _loadFeed();
  }

  Future<void> _loadFeed() async {
    final collectorId = _collectorId;
    if (collectorId == null || collectorId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final requests = await _apiService.getCollectorFeed(
        collectorId,
        lat: 6.9271,
        lng: 79.8612,
      );
      if (!mounted) return;
      setState(() => _allRequests = requests);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not load request feed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openSendOfferSheet(CollectionRequestModel request) async {
    if (_collectorId == null || _collectorId!.isEmpty) {
      _showSnackBar('Please log in again to continue.', isError: true);
      return;
    }

    final sent = await SendOfferSheet.show(
      context,
      wasteType: request.wasteType.replaceAll('_', ' '),
      location: request.addressLine,
      preferredTime: _preferredTimeLabel(request),
      onSubmit:
          ({
            required double pricePerUnit,
            required String priceUnit,
            required DateTime proposedPickupAt,
            String? messageToCitizen,
          }) async {
            if (_submittingOffer) return;
            setState(() => _submittingOffer = true);
            try {
              await _apiService.sendCollectorOffer(
                requestId: request.id,
                payload: {
                  'pricePerUnit': pricePerUnit,
                  'priceUnit': priceUnit,
                  'proposedPickupAt': proposedPickupAt
                      .toUtc()
                      .toIso8601String(),
                  'messageToCitizen': messageToCitizen,
                },
              );
            } finally {
              if (mounted) {
                setState(() => _submittingOffer = false);
              }
            }
          },
    );

    if (sent == true && mounted) {
      _showSnackBar('Offer sent successfully.');
      await _loadFeed();
    }
  }

  List<CollectionRequestModel> get _filteredRequests {
    return _allRequests.where((r) {
      final prettyWasteType = r.wasteType.replaceAll('_', ' ').toLowerCase();
      final matchesFilter =
          _selectedFilter == 'All' ||
          prettyWasteType == _selectedFilter.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          prettyWasteType.contains(q) ||
          r.addressLine.toLowerCase().contains(q) ||
          r.citizenName.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  String _preferredTimeLabel(CollectionRequestModel request) {
    final day = _formatDate(request.preferredDate);
    return '$day, ${request.preferredSlot}';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : AppColors.emerald600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredRequests;
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'Browse Requests',
            subtitle: 'See nearby waste pick up requests',
            notificationCount: 1,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFeed,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 14),
                          _buildFilterChips(),
                          const SizedBox(height: 18),
                          Text(
                            '${results.length} request${results.length == 1 ? '' : 's'} available',
                            style: AppTypography.bodySm,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _loading
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 64),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        : results.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverList.separated(
                            itemCount: results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) =>
                                _buildRequestCard(results[i]),
                          ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
        decoration: InputDecoration(
          hintText: 'Search by location or waste type...',
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey400),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.grey400,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = _filters[i];
          final selected = label == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.emerald600 : AppColors.grey100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  color: selected ? Colors.white : AppColors.grey600,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(CollectionRequestModel request) {
    final wasteType = request.wasteType.replaceAll('_', ' ');
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _submittingOffer ? null : () => _openSendOfferSheet(request),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.emerald50,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconSlot(wasteType),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$wasteType Waste',
                            style: AppTypography.titleMd,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.grey400,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  request.citizenName.isEmpty
                                      ? 'Citizen'
                                      : request.citizenName,
                                  style: AppTypography.bodySm,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildMetaItem(
                            Icons.location_on_outlined,
                            request.addressLine,
                          ),
                          const SizedBox(height: 4),
                          _buildMetaItem(
                            Icons.access_time_rounded,
                            _preferredTimeLabel(request),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.grey100),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      color: AppColors.grey400,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.offersCount} offer${request.offersCount == 1 ? '' : 's'} so far',
                      style: AppTypography.caption,
                    ),
                    const Spacer(),
                    Text(
                      _submittingOffer ? 'Sending...' : 'Tap to offer',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.emerald700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSlot(String wasteType) {
    final icon = switch (wasteType) {
      'E WASTE' => Icons.electrical_services_rounded,
      'METAL' => Icons.precision_manufacturing_outlined,
      'ORGANIC' => Icons.eco_outlined,
      'PAPER' => Icons.description_outlined,
      'TEXTILE' => Icons.checkroom_outlined,
      'GLASS' => Icons.wine_bar_outlined,
      _ => Icons.delete_outline_rounded,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.grey100,
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.grey500, size: 28),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey400, size: 13),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTypography.captionSm,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.grey400,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text('No requests found', style: AppTypography.titleMd),
          const SizedBox(height: 4),
          Text(
            'Try a different filter or pull to refresh',
            style: AppTypography.bodySm,
          ),
        ],
      ),
    );
  }
}
