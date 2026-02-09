import 'package:flutter/material.dart';
import '../constants/design_tokens.dart';
import '../models/route_models.dart';
import '../widgets/route_card.dart';
import '../widgets/routes_header.dart';
import '../widgets/collecting_bin_sheet.dart';
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

  /// Track which routes have been started.
  final Set<String> _startedRoutes = {};

  /// Track per-bin collection status for each route.
  /// Key: route ID, Value: list of BinCollectionStatus (one per bin).
  final Map<String, List<BinCollectionStatus>> _binStatuses = {};

  /// Track collection timestamps for each bin in each route.
  /// Key: route ID, Value: Map<binIndex, timestamp>.
  final Map<String, Map<int, DateTime>> _collectedTimestamps = {};

  // ── Sample data (replace with real data source) ───────────────
  final List<RouteData> _routes = [
    const RouteData(
      id: 'ROUTE-001',
      name: 'Downtown Circuit',
      bins: 5,
      distance: 8.5,
      duration: 45,
      progress: 0,
      totalBins: 5,
      status: RouteStatus.highPriority,
    ),
    const RouteData(
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
                        isStarted: _startedRoutes.contains(route.id),
                        bins: _getSampleBinsForRoute(route),
                        binStatuses: _binStatuses[route.id],
                        collectedTimestamps: _collectedTimestamps[route.id],
                        onToggleExpand: () => setState(() {
                          _expandedRoutes[route.id] =
                              !(_expandedRoutes[route.id] ?? false);
                        }),
                        onStartRoute: () => _handleStartRoute(route),
                        onNavigate: () => _handleNavigate(route),
                        onCollectNext: () => _handleCollectNext(route),
                        onSkipBin: () => _handleSkipBin(route),
                        onUndoBin: () => _handleUndoBin(route),
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
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ── Route action handlers ──────────────────────────────────

  void _handleStartRoute(RouteData route) {
    final bins = _getSampleBinsForRoute(route);
    setState(() {
      _startedRoutes.add(route.id);
      // Auto-expand the card when started
      _expandedRoutes[route.id] = true;
      // Initialize bin statuses: first bin = collecting, rest = pending
      _binStatuses[route.id] = List.generate(
        bins.length,
        (i) => i == 0
            ? BinCollectionStatus.collecting
            : BinCollectionStatus.pending,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Route ${route.name} started!'),
        duration: const Duration(seconds: 1),
        backgroundColor: DesignTokens.green700,
      ),
    );
  }

  void _handleNavigate(RouteData route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${route.name}...'),
        duration: const Duration(seconds: 1),
        backgroundColor: DesignTokens.green700,
      ),
    );
  }

  void _handleSkipBin(RouteData route) {
    final statuses = _binStatuses[route.id];
    if (statuses == null) return;

    final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
    if (collectingIndex == -1) return;

    setState(() {
      // Mark current collecting bin as skipped
      statuses[collectingIndex] = BinCollectionStatus.skipped;
      // Record skip timestamp
      _collectedTimestamps[route.id] ??= {};
      _collectedTimestamps[route.id]![collectingIndex] = DateTime.now();
      // Advance to next bin if available
      final nextIndex = collectingIndex + 1;
      if (nextIndex < statuses.length) {
        statuses[nextIndex] = BinCollectionStatus.collecting;
      }

      // Note: Skipped bins do NOT increment progress
      // Progress only increases when bins are actually collected
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bin skipped'),
          duration: Duration(seconds: 1),
          backgroundColor: DesignTokens.grey600,
        ),
      );
    }
  }

  Future<void> _handleCollectNext(RouteData route) async {
    final bins = _getSampleBinsForRoute(route);
    final statuses = _binStatuses[route.id];
    if (statuses == null) return;

    // Find the currently collecting bin
    final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
    if (collectingIndex == -1) return; // No bin currently collecting

    final currentBin = bins[collectingIndex];

    final collected = await CollectingBinSheet.show(
      context,
      bin: currentBin,
      locationName: route.name,
    );

    if (collected == true && mounted) {
      setState(() {
        // Mark current bin as collected
        statuses[collectingIndex] = BinCollectionStatus.collected;

        // Record collection timestamp
        _collectedTimestamps[route.id] ??= {};
        _collectedTimestamps[route.id]![collectingIndex] = DateTime.now();

        // Advance to next bin if available
        final nextIndex = collectingIndex + 1;
        if (nextIndex < statuses.length) {
          statuses[nextIndex] = BinCollectionStatus.collecting;
        }

        // Increment route progress
        final routeIndex = _routes.indexWhere((r) => r.id == route.id);
        if (routeIndex != -1) {
          final current = _routes[routeIndex];
          final newProgress = (current.progress + 1).clamp(
            0,
            current.totalBins,
          );
          _routes[routeIndex] = current.copyWith(
            progress: newProgress,
            status: newProgress >= current.totalBins
                ? RouteStatus.completed
                : current.status,
          );
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentBin.name} marked as collected!'),
            duration: const Duration(seconds: 1),
            backgroundColor: DesignTokens.green700,
          ),
        );
      }
    }
  }

  void _handleUndoBin(RouteData route) {
    final statuses = _binStatuses[route.id];
    if (statuses == null) return;

    // Find the last collected or skipped bin
    int lastCompletedIndex = -1;
    BinCollectionStatus? lastCompletedStatus;
    for (int i = statuses.length - 1; i >= 0; i--) {
      if (statuses[i] == BinCollectionStatus.collected ||
          statuses[i] == BinCollectionStatus.skipped) {
        lastCompletedIndex = i;
        lastCompletedStatus = statuses[i];
        break;
      }
    }

    if (lastCompletedIndex == -1) return;

    // Find current collecting index
    final currentCollectingIndex = statuses.indexOf(
      BinCollectionStatus.collecting,
    );

    setState(() {
      // Mark the last completed/skipped bin back to collecting
      statuses[lastCompletedIndex] = BinCollectionStatus.collecting;

      // If there was a collecting bin, set it back to pending
      if (currentCollectingIndex != -1) {
        statuses[currentCollectingIndex] = BinCollectionStatus.pending;
      }

      // Remove timestamp
      _collectedTimestamps[route.id]?.remove(lastCompletedIndex);

      // Only decrement progress if the bin was actually collected (not skipped)
      if (lastCompletedStatus == BinCollectionStatus.collected) {
        final routeIndex = _routes.indexWhere((r) => r.id == route.id);
        if (routeIndex != -1) {
          final current = _routes[routeIndex];
          final newProgress = (current.progress - 1).clamp(
            0,
            current.totalBins,
          );
          _routes[routeIndex] = current.copyWith(
            progress: newProgress,
            status: RouteStatus.highPriority,
          );
        }
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collection undone'),
          duration: Duration(seconds: 1),
          backgroundColor: DesignTokens.grey600,
        ),
      );
    }
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
