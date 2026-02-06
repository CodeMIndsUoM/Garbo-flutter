import 'package:flutter/material.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  State<CitizenHomePage> createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  int _selectedNavIndex = 0;

  // ── Design tokens ──────────────────────────────────────────────
  // Emerald palette (Tailwind CSS)
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color teal50 = Color(0xFFF0FDFA);

  // Neutrals
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey900 = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                    _buildTipCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: emerald700,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Good morning',
                style: TextStyle(
                  color: Color(0xCCFFFFFF), // white 80%
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // Hamburger menu icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Welcome Card ──────────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: emerald700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: emerald700.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content – NO fixed height, let it size naturally
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User info row
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.white,
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
                        children: [
                          Row(
                            children: const [
                              Flexible(
                                child: Text(
                                  'Hello, Sasindu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('👋', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Let's make our city cleaner",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider
                Container(height: 1, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 14),
                // Eco Points row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.eco,
                          color: Colors.white.withOpacity(0.85),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Eco Points',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
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
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'pts',
                          style: TextStyle(
                            color: Color(0xB3FFFFFF), // white 70%
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
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: grey900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionCard(
              icon: Icons.report_problem_rounded,
              title: 'Report Issue',
              subtitle: 'File a complaint',
              routeName: '/citizen/report',
              hasGradient: true,
            ),
            _buildActionCard(
              icon: Icons.local_shipping_rounded,
              title: 'Request Pickup',
              subtitle: 'Schedule collection',
              routeName: '/citizen/request',
              hasGradient: true,
            ),
            _buildActionCard(
              icon: Icons.event_rounded,
              title: 'Browse Events',
              subtitle: 'Join community',
              routeName: '/citizen/events',
              hasGradient: true,
            ),
            _buildActionCard(
              icon: Icons.bar_chart_rounded,
              title: 'My Activity',
              subtitle: 'Track progress',
              routeName: '/citizen/activity',
              hasGradient: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
    bool hasGradient = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate when the route exists; otherwise show a snackbar
          if (ModalRoute.of(context)?.settings.name != routeName) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title — coming soon'),
                duration: const Duration(seconds: 1),
                backgroundColor: emerald700,
              ),
            );
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: hasGradient
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [emerald50, teal50],
                  )
                : null,
            color: hasGradient ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: emerald700,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: emerald700.withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: grey500,
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

  // ── Recent Activity ───────────────────────────────────────────
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: grey900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _buildActivityItem(
          icon: Icons.check_circle_rounded,
          title: 'Collection completed',
          subtitle: 'Recyclable materials — 10 bags picked up',
          time: '2 hours ago',
        ),
        const SizedBox(height: 10),
        _buildActivityItem(
          icon: Icons.event_available_rounded,
          title: 'Event enrolled',
          subtitle: 'Community Cleanup Drive on Nov 25',
          time: '1 day ago',
        ),
        const SizedBox(height: 10),
        _buildActivityItem(
          icon: Icons.task_alt_rounded,
          title: 'Report resolved',
          subtitle: 'Overflowing bin at Main Street fixed',
          time: '2 days ago',
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      // ❌ removed fixed height — let content size naturally
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon bubble
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: emerald50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: emerald600, size: 22),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: grey600,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: grey500,
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

  // ── Tip Card ──────────────────────────────────────────────────
  Widget _buildTipCard() {
    return Container(
      // ❌ removed fixed height — let content size naturally
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [emerald50, teal50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emerald200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: -1,
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
              color: emerald700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
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
                    color: emerald900,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Separate your recyclables from general waste to help reduce landfill impact and promote sustainability.',
                  style: TextStyle(
                    color: emerald800,
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

  // ── Bottom Navigation ─────────────────────────────────────────
  Widget _buildBottomNavigation() {
    final items = [
      _NavItem(Icons.home_rounded, 'Home'),
      _NavItem(Icons.report_problem_rounded, 'Report'),
      _NavItem(Icons.event_rounded, 'Events'),
      _NavItem(Icons.receipt_long_rounded, 'Requests'),
      _NavItem(Icons.person_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = i == _selectedNavIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedNavIndex = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active indicator bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 32 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isSelected ? emerald700 : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        items[i].icon,
                        color: isSelected ? emerald700 : grey500,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          color: isSelected ? emerald700 : grey500,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Small helper class for nav items
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
