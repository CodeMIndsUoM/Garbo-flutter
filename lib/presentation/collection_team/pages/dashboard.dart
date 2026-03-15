import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/bottom_navigation.dart';
class CollectionTeamDashboard extends StatefulWidget {
  const CollectionTeamDashboard({super.key});

  @override
  State<CollectionTeamDashboard> createState() =>
      CollectionTeamDashboardState();
}
class CollectionTeamDashboardState extends State<CollectionTeamDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLevelCard(),
                  const SizedBox(height: 24),
                  buildTodaysPerformance(),
                  const SizedBox(height: 24),
                  buildTodaysRoutes(),
                  const SizedBox(height: 24),
                  buildRecentAchievements(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 0),
    );
  }

  Widget buildLevelCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue50, AppColors.indigo50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue200, width: 1.27),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.blue500,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level 12',
                        style: TextStyle(
                          color: AppColors.grey900,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Elite Collector',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '1750 pts',
                    style: TextStyle(
                      color: AppColors.blue600,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '750 to Level 13',
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.70,
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.blue500,
              ),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTodaysPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Performance",
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.62,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            buildPerformanceCard(
              icon: Icons.delete_outline_rounded,
              value: '0',
              label: 'Bins Collected',
              subtext: '8 total today',
              iconBg: AppColors.emeraldLight,
              iconColor: AppColors.emerald600,
              subtextColor: AppColors.emerald600,
            ),
            buildPerformanceCard(
              icon: Icons.route_rounded,
              value: '0',
              label: 'Routes Done',
              subtext: '2 total routes',
              iconBg: AppColors.blue100,
              iconColor: AppColors.blue600,
              subtextColor: AppColors.blue600,
            ),
            buildPerformanceCard(
              icon: Icons.trending_up_rounded,
              value: '96%',
              label: 'Efficiency',
              subtext: 'Excellent',
              iconBg: AppColors.purple50,
              iconColor: AppColors.purple600,
              subtextColor: AppColors.purple600,
            ),
            buildPerformanceCard(
              icon: Icons.bolt_rounded,
              value: '+340',
              label: 'Points Today',
              subtext: 'Keep going!',
              iconBg: AppColors.orange50,
              iconColor: AppColors.orange500,
              subtextColor: AppColors.orange500,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPerformanceCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtext,
    required Color iconBg,
    required Color iconColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100, width: 1.27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.grey600,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtextColor,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTodaysRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.route_rounded, size: 20, color: AppColors.grey900),
            SizedBox(width: 4),
            Text(
              "Today's Routes",
              style: TextStyle(
                color: AppColors.grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        buildRouteCard(
          priority: 'HIGH PRIORITY',
          priorityColor: AppColors.red500,
          priorityBg: AppColors.red100,
          title: 'Downtown Circuit',
          details: '5 bins • 8.5 km • 45 mins',
          gradientColors: const [AppColors.red50, AppColors.orange50],
        ),
        const SizedBox(height: 16),
        buildRouteCard(
          priority: 'PENDING',
          priorityColor: AppColors.grey700,
          priorityBg: AppColors.grey200,
          title: 'Residential North',
          details: '3 bins • 6.2 km • 30 mins',
          gradientColors: null,
        ),
      ],
    );
  }

  Widget buildRouteCard({
    required String priority,
    required Color priorityColor,
    required Color priorityBg,
    required String title,
    required String details,
    List<Color>? gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              )
            : null,
        color: gradientColors == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradientColors != null ? priorityBg : AppColors.grey200,
          width: 1.27,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CollectionTeamRoutes()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green700,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Start Route',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecentAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.emoji_events_rounded,
              size: 20,
              color: AppColors.grey900,
            ),
            SizedBox(width: 4),
            Text(
              'Recent Achievements',
              style: TextStyle(
                color: AppColors.grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        buildAchievementItem(
          icon: Icons.flash_on_rounded,
          title: 'Speed Demon',
          timeAgo: 'Earned 2 days ago',
        ),
        const SizedBox(height: 12),
        buildAchievementItem(
          icon: Icons.star_rounded,
          title: 'Perfect Week',
          timeAgo: 'Earned 1 week ago',
        ),
        const SizedBox(height: 12),
        buildAchievementItem(
          icon: Icons.wb_sunny_rounded,
          title: 'Early Bird',
          timeAgo: 'Earned 3 days ago',
        ),
      ],
    );
  }

  Widget buildAchievementItem({
    required IconData icon,
    required String title,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey100, width: 1.27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.yellow, AppColors.yellowOrange],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.orange500, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.grey500,
            size: 20,
          ),
        ],
      ),
    );
  }
}
