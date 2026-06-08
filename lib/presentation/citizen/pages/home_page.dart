import 'package:flutter/material.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/data/models/citizen_activity_item.dart';
import 'package:garbo_swms/data/sources/api_service.dart';
import 'package:garbo_swms/presentation/citizen/utils/citizen_recent_activity_loader.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';
import 'package:garbo_swms/presentation/shared/widgets/citizen_surface_card.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => CitizenHomePageState();
}

class CitizenHomePageState extends State<CitizenHomePage> {
  final ApiService _apiService = ApiService();

  List<CitizenActivityItem> _activities = [];
  bool _loadingActivities = true;

  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  Future<void> _loadRecentActivity() async {
    setState(() => _loadingActivities = true);
    final loader = CitizenRecentActivityLoader(_apiService);
    final items = await loader.load();
    if (!mounted) return;
    setState(() {
      _activities = items;
      _loadingActivities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CitizenHeader(name: 'Home'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRecentActivity,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    buildWelcomeCard(),
                    const SizedBox(height: 24),
                    buildQuickActions(),
                    const SizedBox(height: 24),
                    buildRecentActivity(),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 0),
    );
  }

  Widget buildWelcomeCard() {
    return CitizenSurfaceCard(
      child: Text(
        "Let's make our city cleaner",
        style: AppTypography.displaySm,
      ),
    );
  }

  Widget buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.h2),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildActionCard(
                icon: Icons.report_problem_rounded,
                title: 'Report Issue',
                subtitle: 'File a complaint',
                routeName: AppRouter.citizenReport,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildActionCard(
                icon: Icons.local_shipping_rounded,
                title: 'Request Pickup',
                subtitle: 'Schedule collection',
                routeName: AppRouter.citizenRequest,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildActionCard(
                icon: Icons.event_rounded,
                title: 'Browse Events',
                subtitle: 'Join community',
                routeName: AppRouter.citizenEvents,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != routeName) {
            Navigator.pushNamed(context, routeName);
          }
        },
        child: CitizenSurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.greenSurface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.green700, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleSm.copyWith(fontSize: 12, height: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionSm.copyWith(height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppTypography.h2),
        const SizedBox(height: 14),
        if (_loadingActivities)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_activities.isEmpty)
          CitizenSurfaceCard(
            child: Text(
              'No recent activity yet',
              style: AppTypography.bodyMd.copyWith(color: AppColors.grey600),
            ),
          )
        else
          ..._activities.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(top: entry.key == 0 ? 0 : 10),
              child: buildActivityItem(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                time: CitizenRecentActivityLoader.formatRelativeTime(
                  item.occurredAt,
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return CitizenSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.greenSurface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.emerald600, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMd),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
