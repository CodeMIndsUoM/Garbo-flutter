import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/complete_collection_sheet.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';

enum _JobStatus { offer, active }

class ThirdPartyMyJobsPage extends StatefulWidget {
  const ThirdPartyMyJobsPage({super.key});

  @override
  State<ThirdPartyMyJobsPage> createState() => _ThirdPartyMyJobsPageState();
}

class _ThirdPartyMyJobsPageState extends State<ThirdPartyMyJobsPage> {
  _JobStatus _tab = _JobStatus.active;

  static final List<_Job> _all = [
    _Job(
      status: _JobStatus.active,
      title: 'Glass Bottles',
      person: 'Robert Garcia',
      location: 'Westside',
      distance: '2.8 km',
      pickup: 'Tomorrow, 1:00 PM - 3:00 PM',
      contact: '+1 (555) 123-4567',
      address: '234 West Street, Westside Plaza, Apartment 8C',
    ),
    _Job(
      status: _JobStatus.active,
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
    _Job(
      status: _JobStatus.active,
      title: 'Metal Scrap',
      person: 'James Lee',
      location: 'Eastside',
      distance: '3.4 km',
      pickup: 'Today, 4:00 PM - 5:30 PM',
      contact: '+1 (555) 222-8899',
      address: '89 Steel Road, Industrial Block 2',
    ),
    _Job(
      status: _JobStatus.offer,
      title: 'Plastic Waste',
      person: 'Sarah Miller',
      location: 'Downtown Area',
      distance: '1.4 km',
      pickup: 'Tomorrow, 10:00 AM - 12:00 PM',
      contact: '+1 (555) 301-2211',
      address: '12 Market Lane, Downtown',
    ),
    _Job(
      status: _JobStatus.offer,
      title: 'Organic Waste',
      person: 'Michael Chen',
      location: 'Green Valley',
      distance: '2.1 km',
      pickup: 'Tomorrow, 9:00 AM - 11:00 AM',
      contact: '+1 (555) 402-7788',
      address: '4 Orchard St, Green Valley',
    ),
    _Job(
      status: _JobStatus.offer,
      title: 'Paper Waste',
      person: 'Olivia Park',
      location: 'Riverside',
      distance: '2.6 km',
      pickup: 'Tomorrow, 3:00 PM - 5:00 PM',
      contact: '+1 (555) 556-4412',
      address: '18 River Ave, Apt 4B',
    ),
    _Job(
      status: _JobStatus.offer,
      title: 'Electronic Waste',
      person: 'Emma Thompson',
      location: 'Tech District',
      distance: '3.8 km',
      pickup: 'Today, 5:00 PM - 7:00 PM',
      contact: '+1 (555) 661-9921',
      address: '221 Circuit Blvd, Suite 7',
    ),
  ];

  List<_Job> get _visible =>
      _all.where((j) => j.status == _tab).toList(growable: false);

  int get _offerCount =>
      _all.where((j) => j.status == _JobStatus.offer).length;
  int get _activeCount =>
      _all.where((j) => j.status == _JobStatus.active).length;

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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: _visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildJobCard(_visible[i]),
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
              count: _offerCount,
              selected: _tab == _JobStatus.offer,
              onTap: () => setState(() => _tab = _JobStatus.offer),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              label: 'Active',
              count: _activeCount,
              selected: _tab == _JobStatus.active,
              onTap: () => setState(() => _tab = _JobStatus.active),
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

  Widget _buildJobCard(_Job j) {
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
          _buildActions(j),
        ],
      ),
    );
  }

  Widget _buildDetailsBox(_Job j) {
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

  Widget _buildActions(_Job j) {
    if (j.status == _JobStatus.offer) {
      return Row(
        children: [
          Expanded(
            child: _buildSecondaryButton(
              icon: Icons.close_rounded,
              label: 'Decline',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildPrimaryButton(
              icon: Icons.check_rounded,
              label: 'Accept',
              onTap: () {},
            ),
          ),
        ],
      );
    }
    return Row(
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
}

class _Job {
  final String? imageUrl;
  final _JobStatus status;
  final String title;
  final String person;
  final String location;
  final String distance;
  final String pickup;
  final String contact;
  final String address;
  final String? startedAt;
  final String? duration;

  _Job({
    // ignore: unused_element_parameter
    this.imageUrl,
    required this.status,
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
