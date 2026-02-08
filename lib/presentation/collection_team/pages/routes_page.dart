import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';
import '../models/route_models.dart';
import '../widgets/route_card.dart';
import '../widgets/routes_header.dart';
import 'dashboard.dart';
import '../widgets/professional_bottom_navigation.dart';

class CollectionTeamRoutes extends StatefulWidget {
  const CollectionTeamRoutes({super.key});

  @override
  State<CollectionTeamRoutes> createState() => _CollectionTeamRoutesState();
}

class _CollectionTeamRoutesState extends State<CollectionTeamRoutes> {
  int _selectedNavIndex = 1; // Routes tab

  /// Track expanded state per route card.
  final Map<String, bool> _expandedRoutes = {};

  // ── Sample data (replace with real data source) ───────────────
  final List<RouteData> _routes = const [
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

  bool get _isAnyRouteExpanded => _expandedRoutes.values.any((v) => v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.grey50,
      body: Column(
        children: [
          const RoutesHeader(),
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
                      child: RouteCard(
                        route: route,
                        isExpanded: _expandedRoutes[route.id] ?? false,
                        bins: _getSampleBinsForRoute(route),
                        onToggleExpand: () => setState(() {
                          _expandedRoutes[route.id] =
                              !(_expandedRoutes[route.id] ?? false);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isAnyRouteExpanded ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: _isAnyRouteExpanded
              ? const SizedBox.shrink()
              : _buildBottomNavigation(),
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────
  Widget _buildSectionTitle() {
    return Text(
      'All Routes (${_routes.length})',
      style: const TextStyle(
        color: DesignTokens.grey900,
        fontSize: 16,
        fontWeight: FontWeight.w700,
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
      activeColor: DesignTokens.green700,
      inactiveColor: DesignTokens.grey500,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(page: const CollectionTeamDashboard()),
          );
        } else {
          setState(() => _selectedNavIndex = index);
        }
      },
    );
  }

  // ── Sample bin data (move to repository/service in production) ─
  List<BinData> _getSampleBinsForRoute(RouteData route) {
    if (route.status == RouteStatus.highPriority) {
      return const [
        BinData(
          id: 'BIN-101',
          name: 'Main Street Plaza',
          address: '123 Main St',
          distance: 0.5,
          duration: 3,
          fillStatus: BinFillStatus.full,
          isUrgent: true,
          nextDistance: 1.2,
          nextEta: 5,
        ),
        BinData(
          id: 'BIN-102',
          name: 'Central Park',
          address: '45 Park Ave',
          distance: 1.2,
          duration: 5,
          fillStatus: BinFillStatus.full,
          isUrgent: true,
          nextDistance: 0.8,
          nextEta: 4,
        ),
        BinData(
          id: 'BIN-103',
          name: 'Downtown Mall',
          address: '789 Commerce Blvd',
          distance: 0.8,
          duration: 4,
          fillStatus: BinFillStatus.half,
          isUrgent: false,
          nextDistance: 1.5,
          nextEta: 6,
        ),
        BinData(
          id: 'BIN-104',
          name: 'Central Library',
          address: '321 Book Lane',
          distance: 1.5,
          duration: 6,
          fillStatus: BinFillStatus.half,
          isUrgent: false,
          nextDistance: 2.0,
          nextEta: 8,
        ),
        BinData(
          id: 'BIN-105',
          name: 'Tech Hub Center',
          address: '555 Innovation Dr',
          distance: 2.0,
          duration: 8,
          fillStatus: BinFillStatus.half,
          isUrgent: false,
        ),
      ];
    }
    return const [
      BinData(
        id: 'BIN-201',
        name: 'Residential Block A',
        address: '10 Oak Street',
        distance: 0.3,
        duration: 2,
        fillStatus: BinFillStatus.half,
        isUrgent: false,
        nextDistance: 0.5,
        nextEta: 3,
      ),
      BinData(
        id: 'BIN-202',
        name: 'Maple Gardens',
        address: '25 Garden Way',
        distance: 0.5,
        duration: 3,
        fillStatus: BinFillStatus.half,
        isUrgent: false,
        nextDistance: 0.7,
        nextEta: 4,
      ),
      BinData(
        id: 'BIN-203',
        name: 'Sunset Apartments',
        address: '88 Sunset Blvd',
        distance: 0.7,
        duration: 4,
        fillStatus: BinFillStatus.half,
        isUrgent: false,
      ),
    ];
  }
}
