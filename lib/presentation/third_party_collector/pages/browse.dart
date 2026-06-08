import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';
import 'package:garbo_swms/presentation/shared/marketplace/marketplace_realtime_listener.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/leaflet_navigation_page.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/send_offer_sheet.dart';
import 'package:provider/provider.dart';

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
  bool _usingLiveLocation = false;
  String? _collectorId;
  List<CollectionRequestModel> _allRequests = const [];
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>? _marketplaceSub;

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _attachMarketplaceListener(),
    );
  }

  @override
  void dispose() {
    _marketplaceSub?.cancel();
    super.dispose();
  }

  void _attachMarketplaceListener() {
    if (!mounted) return;
    _marketplaceSub?.cancel();
    _marketplaceSub = MarketplaceRealtimeListener.attach(
      context.read<WebSocketProvider>(),
      _loadFeed,
    );
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
      final currentPosition = await _tryGetCurrentPosition();
      final requests = await _apiService.getCollectorFeed(
        collectorId,
        lat: currentPosition?.latitude,
        lng: currentPosition?.longitude,
      );
      if (!mounted) return;
      setState(() {
        _allRequests = requests;
        _usingLiveLocation = currentPosition != null;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not load request feed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<Position?> _tryGetCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
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
      imageUrl: request.photoUrl,
      weightKg: request.quantityKgEstimate,
      notes: request.notes,
      onSubmit:
          ({
            double? pricePerUnit,
            String? priceUnit,
            String? exchangeItem,
            required DateTime proposedPickupAt,
            String? messageToCitizen,
          }) async {
            if (_submittingOffer) return;
            setState(() => _submittingOffer = true);
            try {
              final payload = <String, dynamic>{
                'proposedPickupAt': proposedPickupAt.toUtc().toIso8601String(),
                'messageToCitizen': messageToCitizen,
              };

              if (pricePerUnit != null && priceUnit != null) {
                payload['pricePerUnit'] = pricePerUnit;
                payload['priceUnit'] = priceUnit;
              } else if (exchangeItem != null) {
                payload['exchangeItem'] = exchangeItem;
              }

              await _apiService.sendCollectorOffer(
                requestId: request.id,
                payload: payload,
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

  void _openPickupMap(CollectionRequestModel request) {
    final lat = request.latitude;
    final lng = request.longitude;

    if (lat == 0 || lng == 0) {
      _showSnackBar(
        'Pickup location coordinates are not available.',
        isError: true,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeafletNavigationPage(
          latitude: lat,
          longitude: lng,
          title: '${request.wasteType.replaceAll('_', ' ')} Waste',
          subtitle: request.addressLine,
        ),
      ),
    );
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
        backgroundColor: isError ? AppColors.redDark2 : AppColors.green700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredRequests;
    return Scaffold(
      backgroundColor: AppColors.grey50,
      extendBody: true,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'Browse Requests',
            subtitle: 'See nearby waste pick up requests',
          ),
          Padding(
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
                const SizedBox(height: 6),
                Text(
                  _usingLiveLocation
                      ? 'Using live GPS for nearby requests'
                      : 'Location unavailable: showing general open requests',
                  style: AppTypography.captionSm,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFeed,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _loading
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 64),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.green700,
                                ),
                              ),
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
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
        border: Border.all(color: AppColors.grey200, width: 1.2),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
        decoration: AppDecorations.searchInput(
          hintText: 'Search by location or waste type...',
          hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.grey400),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.grey400,
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((label) {
          final selected = label == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.green700 : AppColors.grey100,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  label,
                  style: AppTypography.labelMd.copyWith(
                    color: selected ? Colors.white : AppColors.grey600,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestCard(CollectionRequestModel request) {
    final wasteType = request.wasteType.replaceAll('_', ' ');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _submittingOffer ? null : () => _openSendOfferSheet(request),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.emerald50,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSm,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconSlot(wasteType, request.photoUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$wasteType Waste', style: AppTypography.titleMd),
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
                      color: AppColors.green800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryActionButton(
                      icon: Icons.map_outlined,
                      label: 'View Map',
                      onTap: () => _openPickupMap(request),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPrimaryActionButton(
                      icon: Icons.local_offer_outlined,
                      label: 'Send Offer',
                      onTap: _submittingOffer
                          ? null
                          : () => _openSendOfferSheet(request),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.green700,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.buttonMd.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.emerald50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.green800, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.buttonMd.copyWith(
                  color: AppColors.green800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSlot(String wasteType, String? imageUrl) {
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
        child: imageUrl == null || imageUrl.trim().isEmpty
            ? Icon(icon, color: AppColors.grey500, size: 28)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 72,
                height: 72,
                cacheWidth: 216,
                cacheHeight: 216,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) =>
                    Icon(icon, color: AppColors.grey500, size: 28),
              ),
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
