import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/models/collector_dashboard_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/third_party_collector/widgets/header.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/browse.dart';
import 'package:garbo_swms/presentation/third_party_collector/pages/my_jobs.dart';

class ThirdPartyHome extends StatefulWidget {
  const ThirdPartyHome({super.key});

  @override
  State<ThirdPartyHome> createState() => _ThirdPartyHomeState();
}

class _ThirdPartyHomeState extends State<ThirdPartyHome> {
  final ApiService _apiService = ApiService();

  bool _loadingCompleted = false;
  String? _collectorId;
  CollectorDashboardModel? _dashboardModel;
  List<_Collection> _completedCollections = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final collectorId = await _apiService.getStoredEmpId();
    if (!mounted) return;
    setState(() => _collectorId = collectorId);
    await _loadCompletedCollections();
  }

  Future<void> _loadCompletedCollections() async {
    final collectorId = _collectorId;
    if (collectorId == null || collectorId.isEmpty) return;

    setState(() => _loadingCompleted = true);
    try {
      final dashboard = await _apiService.getCollectorDashboard(collectorId);

      final completedOffers = await _apiService.getCollectorOffers(
        collectorId,
        status: 'COMPLETED',
      );

      final requestIds = completedOffers.map((o) => o.requestId).toSet();
      final details = await Future.wait(
        requestIds.map((id) => _apiService.getCollectionRequestDetail(id)),
      );
      final requestById = {for (final request in details) request.id: request};

      final rows = completedOffers
          .map((offer) {
            final request = requestById[offer.requestId];
            return _Collection.fromOffer(offer: offer, request: request);
          })
          .toList(growable: false);

      rows.sort((a, b) => b.sortTime.compareTo(a.sortTime));

      if (!mounted) return;
      setState(() {
        _completedCollections = rows;
        _dashboardModel = dashboard;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _completedCollections = const []);
    } finally {
      if (mounted) {
        setState(() => _loadingCompleted = false);
      }
    }
  }

  Widget _buildSectionTitle(String title, {bool big = false}) {
    return Text(title, style: big ? AppTypography.h3 : AppTypography.h4);
  }

  Widget _buildCompletedSectionHeader() {
    final hasMore = _completedCollections.length > 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildSectionTitle('Completed Collections', big: true)),
        if (hasMore)
          TextButton(
            onPressed: _openAllCompleted,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.green700,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all (${_completedCollections.length})',
                  style: AppTypography.titleSm.copyWith(
                    color: AppColors.green700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.green700,
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _openAllCompleted() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AllCompletedCollectionsPage(
          collections: _completedCollections,
          cardBuilder: _buildCollectionCard,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      extendBody: true,
      body: Column(
        children: [
          const ThirdPartyHeader(
            title: 'Home',
            subtitle: 'Lets gets things done smoothly',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCompletedCollections,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Today's Summary"),
                    const SizedBox(height: 12),
                    _buildTodaysImpactCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Quick Actions'),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Performance Metrics'),
                    const SizedBox(height: 12),
                    _buildPerformanceMetrics(),
                    const SizedBox(height: 24),
                    _buildCompletedSectionHeader(),
                    const SizedBox(height: 12),
                    if (_loadingCompleted)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_completedCollections.isEmpty)
                      _buildEmptyCompleted()
                    else
                      ..._completedCollections
                          .take(2)
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCollectionCard(c),
                            ),
                          ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ThirdPartyBottomNavbar(currentIndex: 0),
    );
  }

  // DEVELOPER NOTE: Welcome banner container (styling for background color, border radius, and shadow offsets is defined below).
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatPill(
                  _dashboardModel?.availableRequests.toString() ?? '-',
                  'Available',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatPill(
                  _dashboardModel?.activeJobs.toString() ?? '-',
                  'Active',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatPill(
                  _dashboardModel?.completedJobs.toString() ?? '-',
                  'Completed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // DEVELOPER NOTE: Dashboard metrics stat pill (adjust width, height, colors, and layout structure of metrics cards here).
  Widget _buildStatPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey100, width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.displayMd.copyWith(color: AppColors.grey900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.captionSm.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  // DEVELOPER NOTE: Today's Impact Card layout (control typography, background card margins/padding, colors, and icon alignments below).
  Widget _buildTodaysImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildImpactTile(
                  _formatMinutes(_dashboardModel?.todaysWorkingMinutes ?? 0),
                  'Working Hours',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImpactTile(
                  '${_dashboardModel?.todaysWasteCollectedKg.toStringAsFixed(2) ?? '0.00'} Kg',
                  'Waste Collected',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey100, width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.displaySm.copyWith(color: AppColors.grey900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.captionSm.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.search_rounded,
          title: 'Browse Requests',
          subtitle: 'See nearby requests to offer on',
          primary: true,
          onTap: () {
            Navigator.of(
              context,
            ).pushReplacement(SmoothPageRoute(page: ThirdPartyBrowsePage()));
          },
        ),
        const SizedBox(height: 10),
        _buildActionButton(
          icon: Icons.local_offer_outlined,
          title: 'My Offers',
          subtitle: 'Track pending and accepted offers',
          primary: false,
          onTap: () {
            Navigator.of(
              context,
            ).pushReplacement(SmoothPageRoute(page: ThirdPartyMyJobsPage()));
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool primary,
    required VoidCallback onTap,
  }) {
    final bgColor = Colors.white;
    final titleColor = AppColors.grey900;
    final subColor = AppColors.grey600;
    final iconColor = AppColors.green700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.buttonLg.copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(color: subColor),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey900,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Column(
        children: [
          _buildMetricRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Response Rate',
            value: '${_dashboardModel?.responseRate.toInt() ?? 0}%',
          ),
          _buildDivider(),
          _buildMetricRow(
            icon: Icons.access_time_rounded,
            label: 'On-Time Rate',
            value: '${_dashboardModel?.onTimeRate.toInt() ?? 0}%',
          ),
          _buildDivider(),
          _buildMetricRow(
            icon: Icons.star_border_rounded,
            label: 'Average Rating',
            value:
                '${_dashboardModel?.overallRating.toStringAsFixed(1) ?? '0.0'} / 5.0',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppColors.grey100);
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(color: AppColors.green700),
            ),
          ),
          Text(
            value,
            style: AppTypography.titleLg.copyWith(color: AppColors.green700),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(_Collection c) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCollectionImage(c.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: AppTypography.titleMd),
                              const SizedBox(height: 2),
                              Text(c.customer, style: AppTypography.bodySm),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRatingChip(c.rating),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildMetaRow(c),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.grey100),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 14,
                color: AppColors.grey400,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(c.quote, style: AppTypography.quote)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionImage(String? imageUrl) {
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
                cacheWidth: 216,
                cacheHeight: 216,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.grey300,
                  size: 28,
                ),
              ),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    final hasRating = rating > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.amber600, size: 13),
          const SizedBox(width: 3),
          Text(
            hasRating ? rating.toStringAsFixed(1) : 'N/A',
            style: AppTypography.captionSm.copyWith(
              color: AppColors.amber600,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(_Collection c) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        _buildMetaItem(Icons.location_on_outlined, c.location),
        _buildMetaItem(Icons.calendar_today_outlined, c.date),
        _buildMetaItem(Icons.access_time_rounded, c.time),
      ],
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.grey400, size: 12),
        const SizedBox(width: 3),
        Text(text, style: AppTypography.captionSm),
      ],
    );
  }

  Widget _buildEmptyCompleted() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            color: AppColors.grey400,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text('No completed collections yet', style: AppTypography.titleMd),
          const SizedBox(height: 4),
          Text(
            'Completed pickups will appear here with citizen feedback.',
            style: AppTypography.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int totalMinutes) {
    if (totalMinutes == 0) return '0h 0m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

class _Collection {
  final String? imageUrl;
  final String title;
  final String customer;
  final String location;
  final String date;
  final String time;
  final double rating;
  final String quote;
  final DateTime sortTime;

  _Collection({
    this.imageUrl,
    required this.title,
    required this.customer,
    required this.location,
    required this.date,
    required this.time,
    required this.rating,
    required this.quote,
    required this.sortTime,
  });

  factory _Collection.fromOffer({
    required CollectionOfferModel offer,
    required CollectionRequestModel? request,
  }) {
    final completedTime = offer.completedAt ?? offer.proposedPickupAt;
    final photoUrl = offer.completionPhotoUrl?.trim();
    return _Collection(
      imageUrl: photoUrl != null && photoUrl.isNotEmpty ? photoUrl : null,
      title: request == null
          ? 'Request #${offer.requestId}'
          : '${request.wasteType.replaceAll('_', ' ')} Waste',
      customer: request?.citizenName.isNotEmpty == true
          ? request!.citizenName
          : 'Citizen',
      location: request?.addressLine ?? 'Location unavailable',
      date: _formatStaticDate(completedTime.toLocal()),
      time: _formatStaticTime(completedTime.toLocal()),
      rating: (offer.citizenRating ?? 0).toDouble(),
      quote: offer.citizenFeedback ?? 'Collection completed successfully.',
      sortTime: completedTime,
    );
  }

  static String _formatStaticDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _formatStaticTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final meridiem = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $meridiem';
  }
}

class _AllCompletedCollectionsPage extends StatelessWidget {
  final List<_Collection> collections;
  final Widget Function(_Collection) cardBuilder;

  const _AllCompletedCollectionsPage({
    required this.collections,
    required this.cardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          'Completed Collections',
          style: AppTypography.h3.copyWith(color: AppColors.grey900),
        ),
      ),
      body: collections.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: AppColors.grey400,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No completed collections yet',
                      style: AppTypography.titleMd,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: collections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => cardBuilder(collections[i]),
            ),
    );
  }
}
