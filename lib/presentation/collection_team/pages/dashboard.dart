import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/collection_team/pages/routes_page.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/professional_bottom_navigation.dart';

class CollectionTeamDashboard extends StatefulWidget {
  const CollectionTeamDashboard({super.key});

  @override
  State<CollectionTeamDashboard> createState() =>
      _CollectionTeamDashboardState();
}

class _CollectionTeamDashboardState extends State<CollectionTeamDashboard> {
  int _selectedNavIndex = 0;

  // ── Design tokens ──────────────────────────────────────────────
  // Primary green (darker than citizen emerald)
  static const Color green700 = Color(0xFF03824B);
  static const Color green800 = Color(0xFF026639);

  // Accent colors
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue500 = Color(0xFF2B7FFF);
  static const Color blue600 = Color(0xFF155DFC);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red500 = Color(0xFFFB2C36);
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange500 = Color(0xFFF54900);

  static const Color emeraldLight = Color(0xFFDCFCE7);
  static const Color emerald600 = Color(0xFF00A63E);

  static const Color purple50 = Color(0xFFF3E8FF);
  static const Color purple600 = Color(0xFF9810FA);

  static const Color yellow = Color(0xFFFEF9C2);
  static const Color yellowOrange = Color(0xFFFFEDD4);

  // Neutrals
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey500 = Color(0xFF6A7282);
  static const Color grey600 = Color(0xFF4A5565);
  static const Color grey900 = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLevelCard(),
                  const SizedBox(height: 24),
                  _buildTodaysPerformance(),
                  const SizedBox(height: 24),
                  _buildTodaysRoutes(),
                  const SizedBox(height: 24),
                  _buildRecentAchievements(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      decoration: BoxDecoration(
        color: green700,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 15,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with menu button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection Team',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hello, Thanoj!',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF), // white 90%
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                _buildHeaderStat('0/8', 'Collected', null),
                const SizedBox(width: 17),
                _buildHeaderStat('2340', 'Points', Icons.bolt),
                const SizedBox(width: 17),
                _buildHeaderStat(
                  '24',
                  'Day Streak',
                  Icons.local_fire_department,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData? icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Level Card ────────────────────────────────────────────────
  Widget _buildLevelCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue50, Color(0xFFEEF2FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBEDBFF), width: 1.27),
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
                      color: blue500,
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
                          color: grey900,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Elite Collector',
                        style: TextStyle(
                          color: grey600,
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
                    '2340 pts',
                    style: TextStyle(
                      color: blue600,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '160 to Level 13',
                    style: TextStyle(
                      color: grey500,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.87,
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(blue500),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Today's Performance ───────────────────────────────────────
  Widget _buildTodaysPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Performance",
          style: TextStyle(
            color: grey900,
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
            _buildPerformanceCard(
              icon: Icons.delete_outline_rounded,
              value: '0',
              label: 'Bins Collected',
              subtext: '8 total today',
              iconBg: emeraldLight,
              iconColor: emerald600,
              subtextColor: emerald600,
            ),
            _buildPerformanceCard(
              icon: Icons.route_rounded,
              value: '0',
              label: 'Routes Done',
              subtext: '2 total routes',
              iconBg: blue100,
              iconColor: blue600,
              subtextColor: blue600,
            ),
            _buildPerformanceCard(
              icon: Icons.trending_up_rounded,
              value: '96%',
              label: 'Efficiency',
              subtext: 'Excellent',
              iconBg: purple50,
              iconColor: purple600,
              subtextColor: purple600,
            ),
            _buildPerformanceCard(
              icon: Icons.bolt_rounded,
              value: '+340',
              label: 'Points Today',
              subtext: 'Keep going!',
              iconBg: orange50,
              iconColor: orange500,
              subtextColor: orange500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtext,
    required Color iconBg,
    required Color iconColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: grey100, width: 1.27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
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
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: grey900,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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
              color: grey600,
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
    );
  }

  // ── Today's Routes ────────────────────────────────────────────
  Widget _buildTodaysRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.route_rounded, size: 20, color: grey900),
            SizedBox(width: 4),
            Text(
              "Today's Routes",
              style: TextStyle(
                color: grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRouteCard(
          priority: 'HIGH PRIORITY',
          priorityColor: red500,
          priorityBg: const Color(0xFFFFC9C9),
          title: 'Downtown Circuit',
          details: '5 bins • 8.5 km • 45 mins',
          gradientColors: const [red50, Color(0xFFFFF7ED)],
        ),
        const SizedBox(height: 12),
        _buildRouteCard(
          priority: 'PENDING',
          priorityColor: const Color(0xFF364153),
          priorityBg: grey200,
          title: 'Residential North',
          details: '3 bins • 6.2 km • 30 mins',
          gradientColors: null,
        ),
      ],
    );
  }

  Widget _buildRouteCard({
    required String priority,
    required Color priorityColor,
    required Color priorityBg,
    required String title,
    required String details,
    List<Color>? gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 12),
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
          color: gradientColors != null ? priorityBg : grey200,
          width: 1.27,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority badge
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
              color: grey900,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            details,
            style: const TextStyle(
              color: grey600,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          // Start Route button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Route navigation — coming soon'),
                    duration: Duration(seconds: 1),
                    backgroundColor: green700,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green700,
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

  // ── Recent Achievements ───────────────────────────────────────
  Widget _buildRecentAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.emoji_events_rounded, size: 20, color: grey900),
            SizedBox(width: 4),
            Text(
              'Recent Achievements',
              style: TextStyle(
                color: grey900,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAchievementItem(
          icon: Icons.flash_on_rounded,
          title: 'Speed Demon',
          timeAgo: 'Earned 2 days ago',
        ),
        const SizedBox(height: 8),
        _buildAchievementItem(
          icon: Icons.star_rounded,
          title: 'Perfect Week',
          timeAgo: 'Earned 1 week ago',
        ),
        const SizedBox(height: 8),
        _buildAchievementItem(
          icon: Icons.wb_sunny_rounded,
          title: 'Early Bird',
          timeAgo: 'Earned 3 days ago',
        ),
      ],
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required String timeAgo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: grey100, width: 1.27),
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
                colors: [yellow, yellowOrange],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: orange500, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: grey500,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: grey500, size: 20),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────
  Widget _buildBottomNavigation() {
    final items = [
      const NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
      const NavItem(icon: Icons.route_rounded, label: 'Routes'),
      const NavItem(icon: Icons.map_rounded, label: 'Map'),
      const NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return ProfessionalBottomNavigation(
      currentIndex: _selectedNavIndex,
      items: items,
      activeColor: green700,
      inactiveColor: grey500,
      onTap: (index) {
        if (index == 1) {
          // Navigate to Routes
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const CollectionTeamRoutes()),
          );
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
    );
  }
}

// Helper class for nav items
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
