import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/citizen/widgets/bottom_navbar.dart';
import 'package:garbo_swms/core/router/app_router.dart';
import 'package:garbo_swms/presentation/citizen/widgets/header.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => CitizenHomePageState();
}

class CitizenHomePageState extends State<CitizenHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CitizenHeader(name: 'Home'),
          Expanded(
            child: SingleChildScrollView(
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
                  const SizedBox(height: 24),
                  buildTipCard(),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CitizenBottomNavbar(currentIndex: 0),
    );
  }

  Widget buildWelcomeCard() {
    return Container(
      width: double.infinity,
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
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.emerald200,
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: AppColors.green700,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Let's make our city cleaner",
                        style: TextStyle(
                          color: AppColors.grey900,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.grey200),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.eco,
                      color: AppColors.green700,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Eco Points',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '145',
                      style: TextStyle(
                        color: AppColors.grey900,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'pts',
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            buildActionCard(
              icon: Icons.report_problem_rounded,
              title: 'Report Issue',
              subtitle: 'File a complaint',
              routeName: AppRouter.citizenReport,
            ),
            buildActionCard(
              icon: Icons.local_shipping_rounded,
              title: 'Request Pickup',
              subtitle: 'Schedule collection',
              routeName: AppRouter.citizenRequest,
            ),
            buildActionCard(
              icon: Icons.event_rounded,
              title: 'Browse Events',
              subtitle: 'Join community',
              routeName: AppRouter.citizenEvents,
            ),
            buildActionCard(
              icon: Icons.bar_chart_rounded,
              title: 'My Activity',
              subtitle: 'Track progress',
              routeName: AppRouter.citizenProfile,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.greenSurface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.green700, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: AppColors.grey900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        buildActivityItem(
          icon: Icons.check_circle_rounded,
          title: 'Collection completed',
          subtitle: 'Recyclable materials — 10 bags picked up',
          time: '2 hours ago',
        ),
        const SizedBox(height: 10),
        buildActivityItem(
          icon: Icons.event_available_rounded,
          title: 'Event enrolled',
          subtitle: 'Community Cleanup Drive on Nov 25',
          time: '1 day ago',
        ),
        const SizedBox(height: 10),
        buildActivityItem(
          icon: Icons.task_alt_rounded,
          title: 'Report resolved',
          subtitle: 'Overflowing bin at Main Street fixed',
          time: '2 days ago',
        ),
      ],
    );
  }

  Widget buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
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
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.greenSurface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: AppColors.green700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Waste Management Tip',
                  style: TextStyle(
                    color: AppColors.grey900,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Separate your recyclables from general waste to help reduce landfill impact and promote sustainability.',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

