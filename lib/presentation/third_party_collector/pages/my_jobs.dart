import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
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
  _TabType _tab = _TabType.offer;

  static final List<_ActiveJob> _activeJobs = [
    _ActiveJob(
      title: 'Glass Bottles',
      person: 'Robert Garcia',
      location: 'Westside',
      distance: '2.8 km',
      pickup: 'Tomorrow, 1:00 PM - 3:00 PM',
      contact: '+1 (555) 123-4567',
      address: '234 West Street, Westside Plaza, Apartment 8C',
    ),
    _ActiveJob(
      title: 'Textile Waste',
      person: 'Amanda Foster',
      location: 'Northside',
      distance: '1.2 km',
      pickup: 'Today, 6:00 PM - 8:00 PM',
      contact: '+1 (555) 987-6543',
      address: '567 North Avenue, Building C, Floor 3',
      startedAt: '5:45 PM',
      duration: '30 mins',
    ),
    _ActiveJob(
      title: 'Metal Scrap',
      person: 'James Lee',
      location: 'Eastside',
      distance: '3.4 km',
      pickup: 'Today, 4:00 PM - 5:30 PM',
      contact: '+1 (555) 222-8899',
      address: '89 Steel Road, Industrial Block 2',
    ),
  ];

  static final List<_Offer> _offers = [
    _Offer(
      title: 'Plastic Waste',
      person: 'Sarah Miller',
      location: 'Downtown Area',
      distance: '1.4 km',
      postedAgo: '2 hrs ago',
      offerStatus: OfferStatus.pending,
    ),
    _Offer(
      title: 'Electronic Waste',
      person: 'Emma Thompson',
      location: 'Tech District',
      distance: '3.8 km',
      postedAgo: '5 hrs ago',
      offerStatus: OfferStatus.pending,
    ),
    _Offer(
      title: 'Organic Waste',
      person: 'Michael Chen',
      location: 'Green Valley',
      distance: '2.1 km',
      postedAgo: '1 hrs ago',
      offerStatus: OfferStatus.accepted,
      pickup: 'Tomorrow, 9:00 AM - 11:00 AM',
      contact: '+1 (555) 402-7788',
      address: '4 Orchard St, Green Valley',
    ),
    _Offer(
      title: 'Organic Waste',
      person: 'Michael Chen',
      location: 'Green Valley',
      distance: '2.1 km',
      postedAgo: '1 hrs ago',
      offerStatus: OfferStatus.rejected,
    ),
  ];

  List<_Offer> _offersByStatus(OfferStatus s) =>
      _offers.where((o) => o.offerStatus == s).toList(growable: false);

  static const _offerTabs = [
    (OfferStatus.pending, 'Awaiting'),
    (OfferStatus.accepted, 'Accepted'),
    (OfferStatus.rejected, 'Rejected'),
  ];

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildTabs(),
                  ),
                ),
                if (_tab == _TabType.offer) ...[
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
                  ),
                ],
                if (_tab == _TabType.active)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList.separated(
                      itemCount: _activeJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _buildActiveCard(_activeJobs[i]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 2),
    );
  }

  // ── Tabs ─────────────────────────────────────────────────────────────

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

  // ── Offer Status Tabs (Swipeable) ──────────────────────────────────

  Widget _buildOfferStatusTabs() {
    return Builder(
      builder: (context) {
        final controller = DefaultTabController.of(context);
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.grey200, width: 1),
            ),
          ),
          child: TabBar(
            isScrollable: false,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.emerald600, width: 2.5),
              insets: EdgeInsets.zero,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
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
          curve: Curves.easeOut,
          style: AppTypography.titleSm.copyWith(
            color: selected ? AppColors.emerald700 : AppColors.grey500,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
          child: Text(label),
        ),
        const SizedBox(width: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.emerald50 : AppColors.grey100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
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
            child: const Icon(
              Icons.work_off_outlined,
              color: AppColors.grey400,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text('No offers found', style: AppTypography.titleMd),
          const SizedBox(height: 4),
          Text(
            'Browse requests to send new offers',
            style: AppTypography.bodySm,
          ),
        ],
      ),
    );
  }

  // ── Offer Card (tappable, no buttons) ────────────────────────────────

  Widget _buildOfferCard(_Offer o) {
    final (Color badgeBg, Color badgeFg, String badgeLabel) =
        switch (o.offerStatus) {
      OfferStatus.pending => (
        AppColors.grey100,
        AppColors.grey600,
        'Pending',
      ),
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
        onTap: () => _openOfferDetails(o),
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
              _buildImageSlot(o.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.title,
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
                    Text(o.person, style: AppTypography.bodySm),
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
                            '${o.location} • ${o.distance}',
                            style: AppTypography.captionSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          o.postedAgo,
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

  void _openOfferDetails(_Offer o) {
    OfferDetailsSheet.show(
      context,
      title: o.title,
      person: o.person,
      location: o.location,
      distance: o.distance,
      postedAgo: o.postedAgo,
      status: o.offerStatus,
      pickup: o.pickup,
      contact: o.contact,
      address: o.address,
    );
  }

  // ── Active Card ──────────────────────────────────────────────────────

  Widget _buildActiveCard(_ActiveJob j) {
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
              _buildImageSlot(j.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(j.title, style: AppTypography.titleMd),
                    const SizedBox(height: 2),
                    Text(j.person, style: AppTypography.bodySm),
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
                            '${j.location} · ${j.distance}',
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
          _buildDetailsBox(j),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: Icons.navigation_outlined,
                  label: 'Navigate',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPrimaryButton(
                  icon: Icons.check_rounded,
                  label: 'Complete',
                  onTap: () => CompleteCollectionSheet.show(
                    context,
                    title: j.title,
                    address: j.address,
                    person: j.person,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsBox(_ActiveJob j) {
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
            value: j.pickup,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact:',
            value: j.contact,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: null,
            value: j.address,
          ),
          if (j.startedAt != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.play_arrow_rounded,
              label: 'Started:',
              value:
                  '${j.startedAt}${j.duration != null ? ' · Duration: ${j.duration}' : ''}',
            ),
          ],
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

  // ── Shared Buttons ───────────────────────────────────────────────────

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

  // ── Image Slot ───────────────────────────────────────────────────────

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
}

// ── Data Models ──────────────────────────────────────────────────────────

class _Offer {
  final String? imageUrl;
  final String title;
  final String person;
  final String location;
  final String distance;
  final String postedAgo;
  final OfferStatus offerStatus;
  final String? pickup;
  final String? contact;
  final String? address;

  _Offer({
    // ignore: unused_element_parameter
    this.imageUrl,
    required this.title,
    required this.person,
    required this.location,
    required this.distance,
    required this.postedAgo,
    required this.offerStatus,
    this.pickup,
    this.contact,
    this.address,
  });
}

class _ActiveJob {
  final String? imageUrl;
  final String title;
  final String person;
  final String location;
  final String distance;
  final String pickup;
  final String contact;
  final String address;
  final String? startedAt;
  final String? duration;

  _ActiveJob({
    // ignore: unused_element_parameter
    this.imageUrl,
    required this.title,
    required this.person,
    required this.location,
    required this.distance,
    required this.pickup,
    required this.contact,
    required this.address,
    this.startedAt,
    this.duration,
  });
}
