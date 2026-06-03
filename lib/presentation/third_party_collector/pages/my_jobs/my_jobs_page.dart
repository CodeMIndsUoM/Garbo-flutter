import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/leaflet_navigation_page.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs/utils/my_jobs_helpers.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs/widgets/job_cards.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs/widgets/jobs_filter_widgets.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs/widgets/jobs_tabs.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/complete_collection_sheet.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/offer_details_sheet.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/cancellation_reason_sheet.dart';
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

  // ─── Lifecycle ──────────────────────────────────────────────────────

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

  // ─── Data loading ───────────────────────────────────────────────────

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

  // ─── Filtering ──────────────────────────────────────────────────────

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

  // ─── User actions ───────────────────────────────────────────────────

  OfferStatus _toSheetStatus(String status) {
    if (status == 'PENDING') return OfferStatus.pending;
    if (status == 'ACCEPTED' || status == 'IN_PROGRESS') {
      return OfferStatus.accepted;
    }
    return OfferStatus.rejected;
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
      postedAgo: postedAgoLabel(offer.createdAt),
      status: _toSheetStatus(offer.status),
      pickup: formatPickup(offer.proposedPickupAt.toLocal()),
      contact: request?.contactPhone,
      address: request?.addressLine,
    );

    if (result != true) return;

    // Wait for the details sheet pop transition to complete before triggering the next sheet
    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    try {
      if (offer.status == 'PENDING') {
        await _apiService.withdrawOffer(offer.id);
        _showSnackBar('Offer withdrawn.');
      } else if (offer.status == 'ACCEPTED' || offer.status == 'IN_PROGRESS') {
        final reason = await _askCancelReason();
        if (reason == null) return;

        // Wait for the cancel reason sheet pop transition to complete before triggering API and snackbar
        await Future.delayed(const Duration(milliseconds: 850));
        if (!mounted) return;

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

  // Modal trigger for choosing cancellation reasons.
  // Pushes the custom CancellationReasonSheet route for slow movement transition.
  Future<String?> _askCancelReason() async {
    return CancellationReasonSheet.show(context);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Widget buildTimeChip(String label, int? days) {
              final selected = localCreatedWithinDays == days;
              return GestureDetector(
                onTap: () {
                  setModalState(() => localCreatedWithinDays = days);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green700 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.green700 : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        const Icon(Icons.check, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label,
                        style: AppTypography.labelMd.copyWith(
                          color: selected ? Colors.white : AppColors.grey700,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget buildWasteChip(String type, bool selected) {
              return GestureDetector(
                onTap: () {
                  setModalState(() {
                    if (selected) {
                      localWasteTypes.remove(type);
                    } else {
                      localWasteTypes.add(type);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.emerald50 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.green700 : AppColors.grey200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Icon(Icons.check, size: 16, color: AppColors.green700),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        type.replaceAll('_', ' '),
                        style: AppTypography.labelMd.copyWith(
                          color: selected ? AppColors.green700 : AppColors.grey700,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Row(
                        children: [
                          Text(
                            'Advanced Filters',
                            style: AppTypography.h3,
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
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Reset',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.green700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search section
                      Text('Search', style: AppTypography.titleSm),
                      const SizedBox(height: 8),
                      TextField(
                        controller: queryController,
                        decoration: InputDecoration(
                          hintText: 'Citizen, address, request id',
                          hintStyle: AppTypography.bodyMd.copyWith(
                            color: AppColors.grey400,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.grey400,
                            size: 22,
                          ),
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.grey200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.green700,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Divider
                      Divider(color: AppColors.grey200, height: 1),
                      const SizedBox(height: 20),
                      // Waste Type section
                      Text('Waste Type', style: AppTypography.titleSm),
                      const SizedBox(height: 12),
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
                          runSpacing: 10,
                          children: wasteTypes
                              .map((type) => buildWasteChip(
                                    type,
                                    localWasteTypes.contains(type),
                                  ))
                              .toList(growable: false),
                        ),
                      const SizedBox(height: 20),
                      // Divider
                      Divider(color: AppColors.grey200, height: 1),
                      const SizedBox(height: 20),
                      // Offer Age section
                      Text('Offer Age', style: AppTypography.titleSm),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: [
                          buildTimeChip('Any', null),
                          buildTimeChip('Last 24h', 1),
                          buildTimeChip('Last 7d', 7),
                          buildTimeChip('Last 30d', 30),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            'Apply Filters',
                            style: AppTypography.buttonLg.copyWith(
                              color: Colors.white,
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
              backgroundColor: AppColors.green700,
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
            ? weightRequired(request.wasteType)
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
      setState(() {
        _activeJobs = _activeJobs
            .where((job) => job.id != offerForCompletion.id)
            .toList(growable: false);
        _offers = _offers
            .where((o) => o.id != offerForCompletion.id)
            .toList(growable: false);
      });
      _showSnackBar('Collection marked as completed.');
      unawaited(_loadData());
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
        backgroundColor: isError ? AppColors.redDark2 : AppColors.green700,
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedWasteTypes.clear();
      _searchQuery = '';
      _createdWithinDays = null;
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────

  // DEVELOPER NOTE: Main build coordinates the job view tabs (Offers vs Active collections),
  // header spacing, scroll structures, search inputs, and filters rail.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'My Jobs',
            subtitle: 'Track your offers and collections',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: JobsTabs(
                        showOffers: _tab == _TabType.offer,
                        offersCount: _myOffersTotal,
                        activeCount: _activeJobs.length,
                        onOffersTap: () =>
                            setState(() => _tab = _TabType.offer),
                        onActiveTap: () =>
                            setState(() => _tab = _TabType.active),
                      ),
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
                              child: JobsFilterBar(
                                offerTabs: _offerTabs,
                                offersByStatus: _offersByStatus,
                                activeFilterCount: _activeFilterCount,
                                onOpenFilters: _openAdvancedFilters,
                              ),
                            ),
                            JobsActiveFiltersRail(
                              searchQuery: _searchQuery,
                              selectedWasteTypes: _selectedWasteTypes,
                              createdWithinDays: _createdWithinDays,
                              onClearSearch: () =>
                                  setState(() => _searchQuery = ''),
                              onRemoveWasteType: (type) => setState(
                                () => _selectedWasteTypes.remove(type),
                              ),
                              onClearDays: () =>
                                  setState(() => _createdWithinDays = null),
                              onClearAll: _clearAllFilters,
                            ),
                            Expanded(
                              child: TabBarView(
                                children: _offerTabs
                                    .map(
                                      (tab) => _buildOfferStatusList(tab.$1),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                            ClearRejectedBar(
                              offersByStatus: _offersByStatus,
                              clearing: _clearingRejected,
                              onClear: _clearRejectedOffers,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: _activeJobs.isEmpty
                          ? const SliverToBoxAdapter(
                              child: EmptyActiveJobs(),
                            )
                          : SliverList.separated(
                              itemCount: _activeJobs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final offer = _activeJobs[i];
                                final request =
                                    _requestById[offer.requestId];
                                return ActiveJobCard(
                                  offer: offer,
                                  request: request,
                                  onNavigate: () {
                                    final lat = request?.latitude ?? 0;
                                    final lng = request?.longitude ?? 0;
                                    if (lat == 0 && lng == 0) {
                                      _showSnackBar(
                                        request?.addressLine ??
                                            'Address unavailable',
                                        isError: true,
                                      );
                                      return;
                                    }

                                    final wasteLabel = request == null
                                        ? 'Request #${offer.requestId}'
                                        : '${request.wasteType.replaceAll('_', ' ')} Waste';

                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            LeafletNavigationPage(
                                          latitude: lat,
                                          longitude: lng,
                                          title: wasteLabel,
                                          subtitle:
                                              request?.addressLine ??
                                                  'Target location',
                                        ),
                                      ),
                                    );
                                  },
                                  onComplete: () =>
                                      _handleComplete(offer),
                                );
                              },
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

  // DEVELOPER NOTE: Renders the lists of offers under various states (Pending, Accepted, Rejected).
  // Customize spacing (e.g. SizedBox height), card paddings, and card components here.
  Widget _buildOfferStatusList(OfferStatus status) {
    final offers = _offersByStatus(status);
    if (offers.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          EmptyOffers(
            hasActiveFilters: _activeFilterCount > 0,
            onClearFilters: _clearAllFilters,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final offer = offers[i];
        return OfferCard(
          offer: offer,
          request: _requestById[offer.requestId],
          onTap: () => _openOfferDetails(offer),
        );
      },
    );
  }
}
