import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/complete_collection_sheet.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/offer_details_sheet.dart';

enum _TabType { offer, active }

class ThirdPartyMyJobsPage extends StatefulWidget {
  const ThirdPartyMyJobsPage({super.key});

  @override
  State<ThirdPartyMyJobsPage> createState() => _ThirdPartyMyJobsPageState();
}

class _ThirdPartyMyJobsPageState extends State<ThirdPartyMyJobsPage> {
  final ApiService _apiService = ApiService();

  _TabType _tab = _TabType.offer;
  bool _loading = false;
  String? _collectorId;

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
    _bootstrap();
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
    return _offers.where((offer) {
      final status = offer.status;
      return switch (tabStatus) {
        OfferStatus.pending => status == 'PENDING',
        OfferStatus.accepted => status == 'ACCEPTED' || status == 'IN_PROGRESS',
        OfferStatus.rejected =>
          status == 'REJECTED' || status == 'WITHDRAWN' || status == 'CANCELLED',
      };
    }).toList(growable: false);
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

  String _postedAgoLabel(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime.toLocal());
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
      postedAgo: _postedAgoLabel(offer.proposedPickupAt),
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
        setState(() {
          _offers = _offers.where((o) => o.id != offer.id).toList(growable: false);
        });
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
              const ListTile(
                title: Text('Select cancellation reason'),
              ),
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

  Future<void> _handleComplete(CollectionOfferModel offer) async {
    try {
      var offerForCompletion = offer;
      if (offerForCompletion.status == 'ACCEPTED') {
        offerForCompletion = await _apiService.startOffer(offerForCompletion.id);
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
        weightRequired: request != null ? _weightRequired(request.wasteType) : false,
      );

      if (completionInput == null) return;

      await _apiService.completeOffer(
        offerId: offerForCompletion.id,
        payload: {
          'photoUrl': 'https://example.com/completion-placeholder.jpg',
          'weightKg': completionInput.weightKg,
          'latitude': 6.9271,
          'longitude': 79.8612,
          'notes': completionInput.notes,
        },
      );

      if (!mounted) return;
      _showSnackBar('Collection marked as completed.');
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not complete collection: $e', isError: true);
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: _buildOfferStatusTabs(),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: _offerTabs
                                    .map((tab) => _buildOfferStatusList(tab.$1))
                                    .toList(growable: false),
                              ),
                            ),
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
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, i) => _buildActiveCard(_activeJobs[i]),
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
              count: _offers.length,
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

  Widget _buildOfferStatusTabs() {
    return Builder(
      builder: (context) {
        final controller = DefaultTabController.of(context);
        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
          ),
          child: TabBar(
            isScrollable: false,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.emerald600, width: 2.5),
              insets: EdgeInsets.zero,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: List.generate(_offerTabs.length, (i) {
              final (status, label) = _offerTabs[i];
              final count = _offersByStatus(status).length;
              return Tab(
                height: 44,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => _buildStatusTabLabel(
                    label,
                    count,
                    controller.index == i,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildStatusTabLabel(String label, int count, bool selected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: AppTypography.titleSm.copyWith(
            color: selected ? AppColors.emerald700 : AppColors.grey500,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
          child: Text(label),
        ),
        const SizedBox(width: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.emerald50 : AppColors.grey100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTypography.captionSm.copyWith(
              color: selected ? AppColors.emerald700 : AppColors.grey500,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 1.1,
            ),
            child: Text('$count'),
          ),
        ),
      ],
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
            child: const Icon(Icons.work_off_outlined, color: AppColors.grey400, size: 30),
          ),
          const SizedBox(height: 14),
          Text('No offers found', style: AppTypography.titleMd),
          const SizedBox(height: 4),
          Text('Browse requests to send new offers', style: AppTypography.bodySm),
        ],
      ),
    );
  }

  Widget _buildOfferCard(CollectionOfferModel offer) {
    final request = _requestById[offer.requestId];
    final sheetStatus = _toSheetStatus(offer.status);
    final (Color badgeBg, Color badgeFg, String badgeLabel) = switch (sheetStatus) {
      OfferStatus.pending => (AppColors.grey100, AppColors.grey600, 'Pending'),
      OfferStatus.accepted => (AppColors.emerald50, AppColors.emerald700, 'Accepted'),
      OfferStatus.rejected => (AppColors.grey100, AppColors.grey500, 'Rejected'),
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
              _buildImageSlot(null),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    Text(request?.citizenName ?? 'Citizen', style: AppTypography.bodySm),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.emerald600, size: 13),
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
                          _postedAgoLabel(offer.proposedPickupAt),
                          style: AppTypography.captionSm.copyWith(color: AppColors.grey400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.grey300, size: 20),
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
              _buildImageSlot(null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wasteLabel, style: AppTypography.titleMd),
                    const SizedBox(height: 2),
                    Text(request?.citizenName ?? 'Citizen', style: AppTypography.bodySm),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.emerald600, size: 13),
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
                  onTap: () => _showSnackBar(
                    request?.addressLine ?? 'Address unavailable',
                  ),
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
                style: AppTypography.buttonMd.copyWith(color: AppColors.emerald700),
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
            ? const Icon(Icons.image_rounded, color: AppColors.grey300, size: 28)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 72,
                height: 72,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_rounded, color: AppColors.grey300, size: 28),
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
            child: const Icon(Icons.playlist_add_check_rounded, color: AppColors.grey400, size: 30),
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
