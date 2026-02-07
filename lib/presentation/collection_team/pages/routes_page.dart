import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/collection_team/pages/dashboard.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/professional_bottom_navigation.dart';

class CollectionTeamRoutes extends StatefulWidget {
  const CollectionTeamRoutes({super.key});

  @override
  State<CollectionTeamRoutes> createState() => _CollectionTeamRoutesState();
}

class _CollectionTeamRoutesState extends State<CollectionTeamRoutes> {
  int _selectedNavIndex = 1; // Routes tab is selected

  // ── Design tokens ──────────────────────────────────────────────
  // Primary green
  static const Color green700 = Color(0xFF03824B);

  // High priority colors
  static const Color red100 = Color(0xFFFFC9C9);
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color orange50 = Color(0xFFFFF7ED);

  // Neutrals
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey500 = Color(0xFF6A7282);
  static const Color grey600 = Color(0xFF4A5565);
  static const Color grey700 = Color(0xFF364153);
  static const Color grey900 = Color(0xFF101828);

  // Sample route data
  final List<RouteData> _routes = [
    RouteData(
      id: 'ROUTE-001',
      name: 'Downtown Circuit',
      bins: 5,
      distance: 8.5,
      duration: 45,
      progress: 0,
      totalBins: 5,
      status: RouteStatus.highPriority,
    ),
    RouteData(
      id: 'ROUTE-002',
      name: 'Residential North',
      bins: 3,
      distance: 6.2,
      duration: 30,
      progress: 0,
      totalBins: 3,
      status: RouteStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionTitle(),
                  const SizedBox(height: 12),
                  ..._routes.map(
                    (route) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildRouteCard(route),
                    ),
                  ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Collection Team',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Hello, Thanoj!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.waving_hand,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                      ],
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

  // ── Section Title ─────────────────────────────────────────────
  Widget _buildSectionTitle() {
    return Text(
      'All Routes (${_routes.length})',
      style: const TextStyle(
        color: grey900,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ── Route Card ────────────────────────────────────────────────
  Widget _buildRouteCard(RouteData route) {
    final bool isHighPriority = route.status == RouteStatus.highPriority;
    final double progressPercent = route.totalBins > 0
        ? route.progress / route.totalBins
        : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 12),
      decoration: BoxDecoration(
        gradient: isHighPriority
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [red50, orange50],
              )
            : null,
        color: isHighPriority ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighPriority ? red100 : grey200,
          width: 1.275,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with badges and expand button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badges
                    Row(
                      children: [
                        _buildStatusBadge(route.status),
                        const SizedBox(width: 8),
                        _buildRouteBadge(route.id),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Route name
                    Text(
                      route.name,
                      style: const TextStyle(
                        color: grey900,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Route details
                    Row(
                      children: [
                        _buildDetailChip(
                          Icons.delete_outline,
                          '${route.bins} bins',
                        ),
                        const SizedBox(width: 16),
                        _buildDetailChip(
                          Icons.location_on_outlined,
                          '${route.distance} km',
                        ),
                        const SizedBox(width: 16),
                        _buildDetailChip(
                          Icons.access_time,
                          '${route.duration} mins',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Expand button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: grey600,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        color: grey600,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${route.progress}/${route.totalBins}',
                      style: const TextStyle(
                        color: grey900,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: grey200,
                    valueColor: const AlwaysStoppedAnimation<Color>(green700),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          // Start Route button (for pending and high priority routes)
          if (route.status != RouteStatus.completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting route...'),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RouteStatus status) {
    final bool isHighPriority = status == RouteStatus.highPriority;

    if (isHighPriority) {
      return const _HighPriorityBadge();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: grey200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'PENDING',
        style: TextStyle(
          color: grey700,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildRouteBadge(String routeId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        routeId,
        style: const TextStyle(
          color: grey600,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: grey600, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: grey600,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
        if (index == 0) {
          // Navigate to Dashboard
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const CollectionTeamDashboard()),
          );
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
    );
  }
}

// ── Data Models ─────────────────────────────────────────────────
enum RouteStatus { highPriority, pending, completed }

class RouteData {
  final String id;
  final String name;
  final int bins;
  final double distance;
  final int duration;
  final int progress;
  final int totalBins;
  final RouteStatus status;

  RouteData({
    required this.id,
    required this.name,
    required this.bins,
    required this.distance,
    required this.duration,
    required this.progress,
    required this.totalBins,
    required this.status,
  });
}

// ── Animated High Priority Badge ────────────────────────────────
class _HighPriorityBadge extends StatefulWidget {
  const _HighPriorityBadge();

  @override
  State<_HighPriorityBadge> createState() => _HighPriorityBadgeState();
}

class _HighPriorityBadgeState extends State<_HighPriorityBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  static const Color red500 = Color(0xFFFB2C36);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Smooth pulse opacity: 0.6 -> 1.0 -> 0.6
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: red500.withValues(alpha: _opacityAnimation.value),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: red500.withValues(alpha: _opacityAnimation.value * 0.4),
                blurRadius: 8 * _opacityAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Text(
            'HIGH PRIORITY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
