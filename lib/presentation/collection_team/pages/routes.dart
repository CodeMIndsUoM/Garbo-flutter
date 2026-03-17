import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/route_model.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import '../widgets/route_card.dart';
import '../widgets/collecting_bin_sheet.dart';
import '../widgets/bottom_navigation.dart';

class CollectionTeamRoutes extends StatefulWidget {
  const CollectionTeamRoutes({super.key});

  @override
  State<CollectionTeamRoutes> createState() => CollectionTeamRoutesState();
}

class CollectionTeamRoutesState extends State<CollectionTeamRoutes> {

  final Map<String, bool> expandedRoutes = {};

  final Set<String> startedRoutes = {};

  final Map<String, List<BinCollectionStatus>> binStatuses = {};

  final Map<String, Map<int, DateTime>> collectedTimestamps = {};

  final List<RouteData> routes = [
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
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const HeaderReduced(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  buildSectionTitle(),
                  const SizedBox(height: 12),
                  ...routes.map(
                    (route) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RouteCard(
                        route: route,
                        isExpanded: expandedRoutes[route.id] ?? false,
                        isStarted: startedRoutes.contains(route.id),
                        bins: getSampleBinsForRoute(route),
                        binStatuses: binStatuses[route.id],
                        collectedTimestamps: collectedTimestamps[route.id],
                        onToggleExpand: () => setState(() {
                          expandedRoutes[route.id] =
                              !(expandedRoutes[route.id] ?? false);
                        }),
                        onStartRoute: () => handleStartRoute(route),
                        onNavigate: () => handleNavigate(route),
                        onCollectNext: () => handleCollectNext(route),
                        onSkipBin: () => handleSkipBin(route),
                        onUndoBin: () => handleUndoBin(route),
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
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 1),
    );
  }

  void handleStartRoute(RouteData route) {
    final bins = getSampleBinsForRoute(route);
    setState(() {
      startedRoutes.add(route.id);
      expandedRoutes[route.id] = true;
      binStatuses[route.id] = List.generate(
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
        backgroundColor: AppColors.green700,
      ),
    );
  }

  void handleNavigate(RouteData route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${route.name}...'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.green700,
      ),
    );
  }

  void handleSkipBin(RouteData route) {
    final statuses = binStatuses[route.id];
    if (statuses == null) return;

    final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
    if (collectingIndex == -1) return;

    setState(() {
      statuses[collectingIndex] = BinCollectionStatus.skipped;
      collectedTimestamps[route.id] ??= {};
      collectedTimestamps[route.id]![collectingIndex] = DateTime.now();
      final nextIndex = collectingIndex + 1;
      if (nextIndex < statuses.length) {
        statuses[nextIndex] = BinCollectionStatus.collecting;
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bin skipped'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.grey600,
        ),
      );
    }
  }

  Future<void> handleCollectNext(RouteData route) async {
    try {
      final bins = getSampleBinsForRoute(route);
      final statuses = binStatuses[route.id];
      if (statuses == null) return;

      final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
      if (collectingIndex == -1) return; 

      final currentBin = bins[collectingIndex];

      final collected = await CollectingBinSheet.show(
        context,
        bin: currentBin,
        locationName: route.name,
      );

      if (collected == true && mounted) {
        setState(() {
          statuses[collectingIndex] = BinCollectionStatus.collected;

          collectedTimestamps[route.id] ??= {};
          collectedTimestamps[route.id]![collectingIndex] = DateTime.now();

          final nextIndex = collectingIndex + 1;
          if (nextIndex < statuses.length) {
            statuses[nextIndex] = BinCollectionStatus.collecting;
          }

          final routeIndex = routes.indexWhere((r) => r.id == route.id);
          if (routeIndex != -1) {
            final current = routes[routeIndex];
            final newProgress = (current.progress + 1).clamp(
              0,
              current.totalBins,
            );
            routes[routeIndex] = current.copyWith(
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
              backgroundColor: AppColors.green700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process collection. Please try again.'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    }
  }

  void handleUndoBin(RouteData route) {
    final statuses = binStatuses[route.id];
    if (statuses == null) return;

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

    final currentCollectingIndex = statuses.indexOf(
      BinCollectionStatus.collecting,
    );

    setState(() {
      statuses[lastCompletedIndex] = BinCollectionStatus.collecting;

      if (currentCollectingIndex != -1) {
        statuses[currentCollectingIndex] = BinCollectionStatus.pending;
      }

      collectedTimestamps[route.id]?.remove(lastCompletedIndex);

      if (lastCompletedStatus == BinCollectionStatus.collected) {
        final routeIndex = routes.indexWhere((r) => r.id == route.id);
        if (routeIndex != -1) {
          final current = routes[routeIndex];
          final newProgress = (current.progress - 1).clamp(
            0,
            current.totalBins,
          );
          routes[routeIndex] = current.copyWith(
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
          backgroundColor: AppColors.grey600,
        ),
      );
    }
  }

  Widget buildSectionTitle() {
    return Text(
      'All Routes (${routes.length})',
      style: const TextStyle(
        color: AppColors.grey900,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  List<BinData> getSampleBinsForRoute(RouteData route) {
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
