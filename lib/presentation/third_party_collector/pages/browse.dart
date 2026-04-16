import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/send_offer_sheet.dart';

class ThirdPartyBrowsePage extends StatefulWidget {
  const ThirdPartyBrowsePage({super.key});

  @override
  State<ThirdPartyBrowsePage> createState() => _ThirdPartyBrowsePageState();
}

class _ThirdPartyBrowsePageState extends State<ThirdPartyBrowsePage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const List<String> _filters = [
    'All',
    'Plastic',
    'Organic',
    'Electronic',
    'Paper',
  ];

  static final List<_Request> _allRequests = [
    _Request(
      title: 'Plastic Waste',
      category: 'Plastic',
      person: 'Sarah Miller',
      rating: 4.9,
      location: 'Downtown Area',
      distance: '1.4 km',
      date: 'Tomorrow',
      timeRange: '10:00 AM - 12:00 PM',
      postedAgo: '2 hours ago',
    ),
    _Request(
      title: 'Organic Waste',
      category: 'Organic',
      person: 'Michael Chen',
      rating: 5.0,
      location: 'Green Valley',
      distance: '2.1 km',
      date: 'Tomorrow',
      timeRange: '10:00 AM - 12:00 PM',
      postedAgo: '4 hours ago',
    ),
    _Request(
      title: 'Electronic Waste',
      category: 'Electronic',
      person: 'Emma Thompson',
      rating: 4.7,
      location: 'Tech District',
      distance: '3.8 km',
      date: 'Today',
      timeRange: '5:00 PM - 7:00 PM',
      postedAgo: '1 hour ago',
    ),
    _Request(
      title: 'Paper Waste',
      category: 'Paper',
      person: 'David Wilson',
      rating: 4.8,
      location: 'Riverside',
      distance: '2.6 km',
      date: 'Tomorrow',
      timeRange: '3:00 PM - 5:00 PM',
      postedAgo: '30 minutes ago',
    ),
    _Request(
      title: 'Plastic Waste',
      category: 'Plastic',
      person: 'Olivia Park',
      rating: 4.6,
      location: 'Eastside',
      distance: '5.0 km',
      date: 'Tomorrow',
      timeRange: '9:00 AM - 11:00 AM',
      postedAgo: '6 hours ago',
    ),
  ];

  List<_Request> get _filteredRequests {
    return _allRequests.where((r) {
      final matchesFilter =
          _selectedFilter == 'All' || r.category == _selectedFilter;
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
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
                  sliver: results.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _buildRequestCard(results[i]),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
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
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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

  Widget _buildRequestCard(_Request r) {
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
          onTap: () => SendOfferSheet.show(
            context,
            wasteType: r.title,
            location: r.location,
            preferredTime: '${r.date}, ${r.timeRange}',
          ),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.emerald50,
          highlightColor: AppColors.emerald50.withValues(alpha: 0.4),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSlot(r.imageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: AppTypography.titleMd),
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
                                  r.person,
                                  style: AppTypography.bodySm,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildRatingPill(r.rating),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildMetaItem(
                            Icons.location_on_outlined,
                            '${r.location} · ${r.distance}',
                          ),
                          const SizedBox(height: 4),
                          _buildMetaItem(
                            Icons.access_time_rounded,
                            '${r.date}, ${r.timeRange}',
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
                      Icons.schedule_rounded,
                      color: AppColors.grey400,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(r.postedAgo, style: AppTypography.caption),
                  ],
                ),
              ],
            ),
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

  Widget _buildRatingPill(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.amber600, size: 11),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.captionSm.copyWith(
              color: AppColors.amber600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            'Try a different filter or search term',
            style: AppTypography.bodySm,
          ),
        ],
      ),
    );
  }
}

class _Request {
  final String? imageUrl;
  final String title;
  final String category;
  final String person;
  final double rating;
  final String location;
  final String distance;
  final String date;
  final String timeRange;
  final String postedAgo;

  _Request({
    // ignore: unused_element_parameter
    this.imageUrl,
    required this.title,
    required this.category,
    required this.person,
    required this.rating,
    required this.location,
    required this.distance,
    required this.date,
    required this.timeRange,
    required this.postedAgo,
  });
}
