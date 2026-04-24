import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/leaflet_navigation_page.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/complete_collection_sheet.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/offer_details_sheet.dart';
import 'package:geolocator/geolocator.dart';

enum _TabType { offer, active }

class ThirdPartyMyJobsPage extends StatefulWidget {
  const ThirdPartyMyJobsPage({super.key});

  @override
  State<ThirdPartyMyJobsPage> createState() => _ThirdPartyMyJobsPageState();
}

class _ThirdPartyMyJobsPageState extends State<ThirdPartyMyJobsPage> {
  final ApiService _apiService = ApiService();
  Timer? _timeTicker;

  _TabType _tab = _TabType.offer;
  bool _loading = false;
  bool _clearingRejected = false;
  String? _collectorId;
  Set<String> _selectedWasteTypes = <String>{};
  String _searchQuery = '';
  int? _createdWithinDays;

  List<CollectionOfferModel> _offers = const [];
  List<CollectionOfferModel> _activeJobs = const [];
  final Map<int, CollectionRequestModel> _requestById = {};

  static const _offerTabs = [
    (OfferStatus.pending, 'Awaiting'),
    (OfferStatus.accepted, 'Accepted'),
    (OfferStatus.rejected, 'Rejected'),
  ];

  @override
  void initState() {
    super.initState();
    _timeTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    _bootstrap();
  }

  @override
  void dispose() {
    _timeTicker?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final collectorId = await _apiService.getStoredEmpId();
    if (!mounted) return;
    setState(() => _collectorId = collectorId);
    await _loadData();
  }

  Future<void> _loadData() async {
    final collectorId = _collectorId;
    if (collectorId == null || collectorId.isEmpty) return;

    setState(() => _loading = true);
    try {
      final offers = await _apiService.getCollectorOffers(collectorId);
      final activeJobs = await _apiService.getCollectorActiveJobs(collectorId);

      final requestIds = <int>{
        ...offers.map((o) => o.requestId),
        ...activeJobs.map((o) => o.requestId),
      };

      final details = await Future.wait(
        requestIds.map((id) => _apiService.getCollectionRequestDetail(id)),
      );

      if (!mounted) return;
      setState(() {
        _offers = offers;
        _activeJobs = activeJobs;
        _requestById
          ..clear()
          ..addEntries(details.map((request) => MapEntry(request.id, request)));
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not load your jobs: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<CollectionOfferModel> _offersByStatus(OfferStatus tabStatus) {
    return _offers
        .where((offer) {
          if (!_matchesAdvancedFilters(offer)) {
            return false;
          }
          final status = offer.status;
          return switch (tabStatus) {
            OfferStatus.pending => status == 'PENDING',
            OfferStatus.accepted =>
              status == 'ACCEPTED' || status == 'IN_PROGRESS',
            OfferStatus.rejected =>
              status == 'REJECTED' ||
                  status == 'WITHDRAWN' ||
                  status == 'CANCELLED',
          };
        })
        .toList(growable: false);
  }

  int get _myOffersTotal {
    return _offerTabs.fold<int>(
      0,
      (sum, tab) => sum + _offersByStatus(tab.$1).length,
    );
  }

  int get _activeFilterCount {
    var count = 0;
    if (_selectedWasteTypes.isNotEmpty) count++;
    if (_searchQuery.trim().isNotEmpty) count++;
    if (_createdWithinDays != null) count++;
    return count;
  }

  bool _matchesAdvancedFilters(CollectionOfferModel offer) {
    final request = _requestById[offer.requestId];
    if (request == null) {
      return _selectedWasteTypes.isEmpty &&
          _searchQuery.trim().isEmpty &&
          _createdWithinDays == null;
    }

    if (_selectedWasteTypes.isNotEmpty &&
        !_selectedWasteTypes.contains(request.wasteType)) {
      return false;
    }

    final trimmedQuery = _searchQuery.trim().toLowerCase();
    if (trimmedQuery.isNotEmpty) {
      final searchable = [
        request.citizenName,
        request.addressLine,
        request.wasteType.replaceAll('_', ' '),
        '#${offer.requestId}',
      ].join(' ').toLowerCase();
      if (!searchable.contains(trimmedQuery)) {
        return false;
      }
    }

    if (_createdWithinDays != null) {
      final createdAt = offer.createdAt;
      if (createdAt == null) {
        return false;
      }
      final diff = DateTime.now().difference(createdAt.toLocal());
      if (diff.isNegative || diff.inDays > _createdWithinDays!) {
        return false;
      }
    }

    return true;
  }

  List<String> get _availableWasteTypes {
    final types = _offers
        .map((offer) => _requestById[offer.requestId]?.wasteType)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    types.sort();
    return types;
  }

  OfferStatus _toSheetStatus(String status) {
    if (status == 'PENDING') return OfferStatus.pending;
    if (status == 'ACCEPTED' || status == 'IN_PROGRESS') {
      return OfferStatus.accepted;
    }
    return OfferStatus.rejected;
  }

  String _formatPickup(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  String _postedAgoLabel(DateTime? dateTime) {
    if (dateTime == null) return 'unknown';

    final diff = DateTime.now().difference(dateTime.toLocal());
    if (diff.isNegative) {
      final ahead = diff.abs();
      if (ahead.inMinutes < 1) return 'soon';
      if (ahead.inHours < 1) return 'in ${ahead.inMinutes} min';
      if (ahead.inDays < 1) return 'in ${ahead.inHours} hrs';
      return 'in ${ahead.inDays} days';
    }

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  bool _weightRequired(String wasteType) {
    return const {'METAL', 'E_WASTE', 'PAPER', 'ORGANIC'}.contains(wasteType);
  }

  Future<void> _openOfferDetails(CollectionOfferModel offer) async {
    final request = _requestById[offer.requestId];
    final result = await OfferDetailsSheet.show(
      context,
      title: request == null
          ? 'Request #${offer.requestId}'
          : '${request.wasteType.replaceAll('_', ' ')} Waste',
      person: request?.citizenName ?? 'Citizen',
      location: request?.addressLine ?? 'Location unavailable',
      distance: 'N/A',
      postedAgo: _postedAgoLabel(offer.createdAt),
      status: _toSheetStatus(offer.status),
      pickup: _formatPickup(offer.proposedPickupAt.toLocal()),
      contact: request?.contactPhone,
      address: request?.addressLine,
    );

    if (result != true) return;

    try {
      if (offer.status == 'PENDING') {
        await _apiService.withdrawOffer(offer.id);
        _showSnackBar('Offer withdrawn.');
      } else if (offer.status == 'ACCEPTED' || offer.status == 'IN_PROGRESS') {
        final reason = await _askCancelReason();
        if (reason == null) return;
        await _apiService.cancelOffer(
          offerId: offer.id,
          reason: reason,
          note: reason == 'OTHER' ? 'Cancelled by collector from app' : null,
        );
        _showSnackBar('Offer cancelled.');
      } else {
        await _apiService.hideOffer(offer.id);
        _showSnackBar('Offer removed from list.');
      }
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not update offer: $e', isError: true);
    }
  }

  Future<String?> _askCancelReason() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        const reasons = [
          'VEHICLE_BREAKDOWN',
          'WRONG_ADDRESS',
          'CITIZEN_UNREACHABLE',
          'ROUTE_CHANGED',
          'OTHER',
        ];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('Select cancellation reason')),
              ...reasons.map(
                (reason) => ListTile(
                  title: Text(reason.replaceAll('_', ' ')),
                  onTap: () => Navigator.of(ctx).pop(reason),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAdvancedFilters() async {
    final wasteTypes = _availableWasteTypes;
    final queryController = TextEditingController(text: _searchQuery);
    final localWasteTypes = Set<String>.from(_selectedWasteTypes);
    var localCreatedWithinDays = _createdWithinDays;

    final shouldApply = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Widget buildTimeChip(String label, int? days) {
              final selected = localCreatedWithinDays == days;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) {
                  setModalState(() => localCreatedWithinDays = days);
                },
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Advanced Filters',
                            style: AppTypography.titleMd,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                localWasteTypes.clear();
                                localCreatedWithinDays = null;
                                queryController.clear();
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Search', style: AppTypography.titleSm),
                      const SizedBox(height: 8),
                      TextField(
                        controller: queryController,
                        decoration: InputDecoration(
                          hintText: 'Citizen, address, request id',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Waste Type', style: AppTypography.titleSm),
                      const SizedBox(height: 8),
                      if (wasteTypes.isEmpty)
                        Text(
                          'No waste types available yet',
                          style: AppTypography.captionSm.copyWith(
                            color: AppColors.grey500,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: wasteTypes
                              .map(
                                (type) => FilterChip(
                                  label: Text(type.replaceAll('_', ' ')),
                                  selected: localWasteTypes.contains(type),
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        localWasteTypes.add(type);
                                      } else {
                                        localWasteTypes.remove(type);
                                      }
                                    });
                                  },
                                ),
                              )
                              .toList(growable: false),
                        ),
                      const SizedBox(height: 14),
                      Text('Offer Age', style: AppTypography.titleSm),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildTimeChip('Any', null),
                          buildTimeChip('Last 24h', 1),
                          buildTimeChip('Last 7d', 7),
                          buildTimeChip('Last 30d', 30),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Apply Filters'),
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

    final appliedQuery = queryController.text.trim();
    queryController.dispose();

    if (shouldApply != true || !mounted) return;
    setState(() {
      _selectedWasteTypes = localWasteTypes;
      _createdWithinDays = localCreatedWithinDays;
      _searchQuery = appliedQuery;
    });
  }

  Future<void> _clearRejectedOffers() async {
    final collectorId = _collectorId;
    if (collectorId == null || collectorId.isEmpty || _clearingRejected) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Rejected Offers'),
        content: const Text(
          'This removes all rejected, withdrawn, and cancelled offers from My Jobs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _clearingRejected = true);
    try {
      final hiddenCount = await _apiService.hideCollectorOffers(
        collectorId: collectorId,
        statuses: const ['REJECTED', 'WITHDRAWN', 'CANCELLED'],
      );
      _showSnackBar(
        hiddenCount > 0
            ? 'Removed $hiddenCount offers from list.'
            : 'No rejected offers to remove.',
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not clear offers: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _clearingRejected = false);
      }
    }
  }

  Future<void> _handleComplete(CollectionOfferModel offer) async {
    try {
      var offerForCompletion = offer;
      if (offerForCompletion.status != 'IN_PROGRESS') {
        try {
          offerForCompletion = await _apiService.startOffer(
            offerForCompletion.id,
          );
        } catch (e) {
          if (!e.toString().contains('Only accepted offers')) {
            rethrow;
          }
        }
        if (!mounted) return;
      }

      final request = _requestById[offer.requestId];
      final completionInput = await CompleteCollectionSheet.show(
        context,
        title: request == null
            ? 'Request #${offer.requestId}'
            : '${request.wasteType.replaceAll('_', ' ')} Waste',
        address: request?.addressLine ?? 'Address unavailable',
        person: request?.citizenName ?? 'Citizen',
        weightRequired: request != null
            ? _weightRequired(request.wasteType)
            : false,
      );

      if (completionInput == null) return;

      final photoPath = completionInput.photoPath;

      final fallbackLat = request?.latitude ?? 6.9271;
      final fallbackLng = request?.longitude ?? 79.8612;
      final currentPosition = await _tryGetCurrentPosition();
      final completionLat = currentPosition?.latitude ?? fallbackLat;
      final completionLng = currentPosition?.longitude ?? fallbackLng;

      await _apiService.completeOffer(
        offerId: offerForCompletion.id,
        photoPath: photoPath,
        weightKg: completionInput.weightKg,
        latitude: completionLat,
        longitude: completionLng,
        notes: completionInput.notes,
      );

      if (!mounted) return;
      _showSnackBar('Collection marked as completed.');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not complete collection: $e', isError: true);
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
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'My Jobs',
            subtitle: 'Track your offers and collections',
            notificationCount: 1,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: _buildTabs(),
                    ),
                  ),
                  if (_loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 64),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_tab == _TabType.offer)
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: DefaultTabController(
                        length: _offerTabs.length,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: _buildFilterBar(),
                            ),
                            _buildActiveFiltersRail(),
                            Expanded(
                              child: TabBarView(
                                children: _offerTabs
                                    .map((tab) => _buildOfferStatusList(tab.$1))
                                    .toList(growable: false),
                              ),
                            ),
                            _buildClearRejectedBar(),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: _activeJobs.isEmpty
                          ? SliverToBoxAdapter(child: _buildEmptyActive())
                          : SliverList.separated(
                              itemCount: _activeJobs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _buildActiveCard(_activeJobs[i]),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              label: 'My Offers',
              count: _myOffersTotal,
              selected: _tab == _TabType.offer,
              onTap: () => setState(() => _tab = _TabType.offer),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              label: 'Active',
              count: _activeJobs.length,
              selected: _tab == _TabType.active,
              onTap: () => setState(() => _tab = _TabType.active),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald600 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$label ($count)',
          style: AppTypography.titleSm.copyWith(
            color: selected ? Colors.white : AppColors.grey600,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Builder(
      builder: (context) {
        final controller = DefaultTabController.of(context);
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      return Row(
                        children: List.generate(_offerTabs.length, (i) {
                          final (status, label) = _offerTabs[i];
                          final count = _offersByStatus(status).length;
                          final selected = controller.index == i;
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => controller.animateTo(i),
                              child: _buildStatusPill(
                                label: label,
                                count: count,
                                selected: selected,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterIconButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusPill({
    required String label,
    required int count,
    required bool selected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ]
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: AppTypography.titleSm.copyWith(
                color: selected ? AppColors.emerald700 : AppColors.grey600,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
              child: Text(label),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? AppColors.emerald50 : AppColors.grey200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: AppTypography.captionSm.copyWith(
                  color: selected ? AppColors.emerald700 : AppColors.grey600,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIconButton() {
    final hasFilters = _activeFilterCount > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: hasFilters ? AppColors.emerald600 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFilters ? AppColors.emerald600 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: hasFilters
            ? [
                BoxShadow(
                  color: AppColors.emerald600.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _openAdvancedFilters,
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
                          color: AppColors.emerald600,
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

  Widget _buildClearRejectedBar() {
    return Builder(
      builder: (context) {
        final controller = DefaultTabController.of(context);
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final rejectedCount = _offersByStatus(OfferStatus.rejected).length;
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
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: AppColors.grey100, width: 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            offset: const Offset(0, -2),
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
                            _buildClearRejectedAction(),
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
      },
    );
  }

  Widget _buildClearRejectedAction() {
    return Material(
      color: _clearingRejected ? AppColors.grey100 : AppColors.emerald600,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _clearingRejected ? null : _clearRejectedOffers,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_clearingRejected)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.emerald600,
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
                _clearingRejected ? 'Clearing...' : 'Clear all',
                style: AppTypography.buttonMd.copyWith(
                  color: _clearingRejected ? AppColors.grey500 : Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersRail() {
    if (_activeFilterCount == 0) return const SizedBox.shrink();

    final chips = <Widget>[];

    if (_searchQuery.trim().isNotEmpty) {
      chips.add(
        _activeFilterChip(
          icon: Icons.search_rounded,
          label: '"${_searchQuery.trim()}"',
          onRemove: () => setState(() => _searchQuery = ''),
        ),
      );
    }

    for (final type in _selectedWasteTypes) {
      chips.add(
        _activeFilterChip(
          icon: Icons.category_outlined,
          label: type.replaceAll('_', ' '),
          onRemove: () => setState(() => _selectedWasteTypes.remove(type)),
        ),
      );
    }

    if (_createdWithinDays != null) {
      final daysLabel = switch (_createdWithinDays!) {
        1 => 'Last 24h',
        7 => 'Last 7d',
        30 => 'Last 30d',
        _ => 'Last ${_createdWithinDays}d',
      };
      chips.add(
        _activeFilterChip(
          icon: Icons.access_time_rounded,
          label: daysLabel,
          onRemove: () => setState(() => _createdWithinDays = null),
        ),
      );
    }

    chips.add(
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedWasteTypes.clear();
              _searchQuery = '';
              _createdWithinDays = null;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Clear all',
            style: AppTypography.captionSm.copyWith(
              color: AppColors.emerald700,
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
              Icon(icon, color: AppColors.emerald700, size: 13),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSm.copyWith(
                    color: AppColors.emerald700,
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

  Widget _buildOfferStatusList(OfferStatus status) {
    final offers = _offersByStatus(status);
    if (offers.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [_buildEmptyOffers()],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildOfferCard(offers[i]),
    );
  }

  Widget _buildEmptyOffers() {
    final filtered = _activeFilterCount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: filtered ? AppColors.emerald50 : AppColors.grey100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              filtered ? Icons.search_off_rounded : Icons.work_off_outlined,
              color: filtered ? AppColors.emerald600 : AppColors.grey400,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            filtered ? 'No matches' : 'No offers found',
            style: AppTypography.titleMd,
          ),
          const SizedBox(height: 4),
          Text(
            filtered
                ? 'Try adjusting or clearing your filters'
                : 'Browse requests to send new offers',
            style: AppTypography.bodySm,
          ),
          if (filtered) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedWasteTypes.clear();
                  _searchQuery = '';
                  _createdWithinDays = null;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.emerald700,
                side: const BorderSide(color: AppColors.emerald600, width: 1),
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

  Widget _buildOfferCard(CollectionOfferModel offer) {
    final request = _requestById[offer.requestId];
    final sheetStatus = _toSheetStatus(offer.status);
    final (
      Color badgeBg,
      Color badgeFg,
      String badgeLabel,
    ) = switch (sheetStatus) {
      OfferStatus.pending => (AppColors.grey100, AppColors.grey600, 'Pending'),
      OfferStatus.accepted => (
        AppColors.emerald50,
        AppColors.emerald700,
        'Accepted',
      ),
      OfferStatus.rejected => (
        AppColors.grey100,
        AppColors.grey500,
        'Rejected',
      ),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openOfferDetails(offer),
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.emerald50,
        child: Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSlot(request?.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request == null
                                ? 'Request #${offer.requestId}'
                                : '${request.wasteType.replaceAll('_', ' ')} Waste',
                            style: AppTypography.titleMd,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeLabel,
                            style: AppTypography.captionSm.copyWith(
                              color: badgeFg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request?.citizenName ?? 'Citizen',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.emerald600,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request?.addressLine ?? 'Location unavailable',
                            style: AppTypography.captionSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _postedAgoLabel(offer.createdAt),
                          style: AppTypography.captionSm.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey300,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCard(CollectionOfferModel offer) {
    final request = _requestById[offer.requestId];
    final wasteLabel = request == null
        ? 'Request #${offer.requestId}'
        : '${request.wasteType.replaceAll('_', ' ')} Waste';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSlot(request?.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wasteLabel, style: AppTypography.titleMd),
                    const SizedBox(height: 2),
                    Text(
                      request?.citizenName ?? 'Citizen',
                      style: AppTypography.bodySm,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.emerald600,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request?.addressLine ?? 'Location unavailable',
                            style: AppTypography.captionSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailsBox(offer, request),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.navigation_outlined,
                  label: 'Navigate',
                  onTap: () {
                    final lat = request?.latitude ?? 0;
                    final lng = request?.longitude ?? 0;
                    if (lat == 0 && lng == 0) {
                      _showSnackBar(
                        request?.addressLine ?? 'Address unavailable',
                        isError: true,
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LeafletNavigationPage(
                          latitude: lat,
                          longitude: lng,
                          title: wasteLabel,
                          subtitle: request?.addressLine ?? 'Target location',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryButton(
                  icon: Icons.check_rounded,
                  label: 'Complete',
                  onTap: () => _handleComplete(offer),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsBox(
    CollectionOfferModel offer,
    CollectionRequestModel? request,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Pickup:',
            value: _formatPickup(offer.proposedPickupAt.toLocal()),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact:',
            value: request?.contactPhone ?? 'Not available',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: null,
            value: request?.addressLine ?? 'Address unavailable',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String? label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: AppColors.grey500, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySm.copyWith(color: AppColors.grey700),
              children: [
                if (label != null)
                  TextSpan(
                    text: '$label ',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.grey900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.emerald600,
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

  Widget _buildSecondaryButton({
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
              Icon(icon, color: AppColors.emerald700, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.buttonMd.copyWith(
                  color: AppColors.emerald700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlot(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.grey100,
        alignment: Alignment.center,
        child: imageUrl == null
            ? const Icon(
                Icons.image_rounded,
                color: AppColors.grey300,
                size: 28,
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 72,
                height: 72,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.grey300,
                  size: 28,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyActive() {
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
