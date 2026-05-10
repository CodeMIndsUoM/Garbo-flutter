import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/route_model.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import 'map.dart';
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
  final Map<String, List<BinData>> routeBinsById = {};
  final List<RouteData> routes = [];

  RouteProvider? _routeProvider;
  bool _providerListenerAttached = false;
  String _lastSnapshotToken = '';
  int? _loadedAssignedForUserId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_providerListenerAttached) {
      _routeProvider = context.read<RouteProvider>();
      _routeProvider!.addListener(_syncFromWebSocket);
      _providerListenerAttached = true;
      _syncFromWebSocket();
    }

    final currentUserId = context.read<AuthProvider>().currentUser?.empId;
    if (currentUserId != null && _loadedAssignedForUserId != currentUserId) {
      _loadedAssignedForUserId = currentUserId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _routeProvider
            ?.loadAssignedRouteForCollector(currentUserId)
            .catchError((error) {
              debugPrint('Failed to load assigned route for collector: $error');
              return null;
            });
      });
    }
  }

  @override
  void dispose() {
    if (_providerListenerAttached && _routeProvider != null) {
      _routeProvider!.removeListener(_syncFromWebSocket);
    }
    super.dispose();
  }

  void _syncFromWebSocket() {
    final provider = _routeProvider;
    if (provider == null) return;

    final history = provider.routeHistory;
    if (history.isEmpty) return;

    final newest = history.last;
    final snapshotToken =
        '${history.length}:${newest.sessionId}:${newest.generatedAt.millisecondsSinceEpoch}';
    if (snapshotToken == _lastSnapshotToken) return;

    final nextRoutes = <RouteData>[];
    final nextBinsByRoute = <String, List<BinData>>{};

    for (final session in history) {
      final routeId = session.sessionId;
      final bins = <BinData>[];

      for (final stop in session.stops) {
        bins.add(
          BinData(
            id: 'BIN-${stop.binId}',
            name: 'Bin ${stop.binId}',
            address:
                stop.address ??
                'Lat ${stop.lat.toStringAsFixed(4)}, Lng ${stop.lng.toStringAsFixed(4)}',
            distance: 0,
            duration: (stop.durationFromPrevStopSeconds / 60).ceil(),
            fillStatus: BinFillStatus.half,
            isUrgent: false,
          ),
        );
      }

      final existing = routes.where((r) => r.id == routeId).firstOrNull;
      final previousProgress = existing?.progress ?? 0;
      final clampedProgress = previousProgress.clamp(0, session.totalStops);

      nextRoutes.add(
        RouteData(
          id: routeId,
          name: session.title,
          bins: session.totalStops,
          distance: 0,
          duration: session.estimatedMinutes,
          progress: clampedProgress,
          totalBins: session.totalStops,
          status: clampedProgress >= session.totalStops
              ? RouteStatus.completed
              : RouteStatus.pending,
        ),
      );
      nextBinsByRoute[routeId] = bins;
    }

    if (!mounted) return;

    setState(() {
      _lastSnapshotToken = snapshotToken;
      routes
        ..clear()
        ..addAll(nextRoutes);

      routeBinsById
        ..clear()
        ..addAll(nextBinsByRoute);

      cleanupStateForRemovedRoutes(routes.map((route) => route.id).toSet());
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<RouteProvider>();

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
                  if (routes.isEmpty)
                    buildNoRoutesCard()
                  else
                    ...routes.map((route) {
                      final bins = getBinsForRoute(route);
                      final displayRoute = _buildDisplayRoute(route, bins);
                      final statuses = _buildDisplayStatuses(route, bins);
                      final timestamps = _buildDisplayTimestamps(route, bins);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RouteCard(
                          route: displayRoute,
                          isExpanded: expandedRoutes[route.id] ?? false,
                          isStarted: startedRoutes.contains(route.id),
                          bins: bins,
                          binStatuses: statuses,
                          collectedTimestamps: timestamps,
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
                      );
                    }),
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
    _routeProvider?.markRouteStarted(route.id);
    setState(() {
      startedRoutes.add(route.id);
      expandedRoutes[route.id] = true;
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
    final provider = _routeProvider;
    if (provider == null) {
      return;
    }

    provider.selectNavigationSession(route.id, startNavigation: true);
    provider.markRouteStarted(route.id);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CollectionTeamMap(
          initialSessionId: route.id,
          autoStartNavigation: true,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${route.name}...'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.green700,
      ),
    );
  }

  void handleSkipBin(RouteData route) {
    final provider = _routeProvider;
    if (provider == null) {
      return;
    }

    final bins = getBinsForRoute(route);
    final statuses = _buildDisplayStatuses(route, bins);
    final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
    if (collectingIndex == -1 || collectingIndex >= bins.length) {
      return;
    }

    final binId = _extractBinId(bins[collectingIndex]);
    if (binId == null) {
      return;
    }

    provider.markBinSkipped(route.id, binId);

    final currentUserId = context.read<AuthProvider>().currentUser?.empId;
    if (currentUserId != null) {
      provider
          .reportRouteCompletionIfEligible(
            userId: currentUserId,
            sessionId: route.id,
          )
          .catchError((_) {});
    }

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
    int? updatedBinId;
    try {
      final provider = _routeProvider;
      if (provider == null) {
        return;
      }

      final bins = getBinsForRoute(route);
      final statuses = _buildDisplayStatuses(route, bins);
      final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
      if (collectingIndex == -1 || collectingIndex >= bins.length) return;

      final currentBin = bins[collectingIndex];
      final collected = await CollectingBinSheet.show(
        context,
        bin: currentBin,
        locationName: route.name,
      );

      if (collected == true && mounted) {
        final authProvider = context.read<AuthProvider>();
        final messenger = ScaffoldMessenger.of(context);
        updatedBinId = _extractBinId(currentBin);
        if (updatedBinId != null) {
          provider.markBinCollected(route.id, updatedBinId);
          final currentUserId = authProvider.currentUser?.empId;
          if (currentUserId != null) {
            await provider.reportBinCollected(
              userId: currentUserId,
              sessionId: route.id,
              binId: updatedBinId,
            );
            try {
              await provider.reportRouteCompletionIfEligible(
                userId: currentUserId,
                sessionId: route.id,
              );
            } catch (e) {
              debugPrint('Route completion reporting skipped after collect: $e');
            }
          }
        }

        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('${currentBin.name} marked as collected!'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.green700,
            ),
          );
        }
      }
    } catch (_) {
      if (updatedBinId != null) {
        _routeProvider?.markBinPending(route.id, updatedBinId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process collection. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    }
  }

  void handleUndoBin(RouteData route) {
    final provider = _routeProvider;
    if (provider == null) {
      return;
    }

    final bins = getBinsForRoute(route);
    if (bins.isEmpty) {
      return;
    }

    final statuses = bins
        .map((bin) {
          final binId = _extractBinId(bin);
          if (binId == null) {
            return BinCollectionStatus.pending;
          }
          return provider.getBinStatus(route.id, binId);
        })
        .toList(growable: false);

    int lastCompletedIndex = -1;
    for (int index = statuses.length - 1; index >= 0; index--) {
      if (statuses[index] == BinCollectionStatus.collected ||
          statuses[index] == BinCollectionStatus.skipped) {
        lastCompletedIndex = index;
        break;
      }
    }

    if (lastCompletedIndex == -1) return;

    final binId = _extractBinId(bins[lastCompletedIndex]);
    if (binId == null) {
      return;
    }

    provider.markBinPending(route.id, binId);

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

  Widget buildNoRoutesCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: const Text(
        'No optimized routes yet. Trigger /api/routes/optimize to receive routes in real-time.',
        style: TextStyle(
          color: AppColors.grey700,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<BinData> getBinsForRoute(RouteData route) {
    return routeBinsById[route.id] ?? const [];
  }

  void cleanupStateForRemovedRoutes(Set<String> activeRouteIds) {
    expandedRoutes.removeWhere(
      (routeId, _) => !activeRouteIds.contains(routeId),
    );
    startedRoutes.removeWhere((routeId) => !activeRouteIds.contains(routeId));
  }

  RouteData _buildDisplayRoute(RouteData route, List<BinData> bins) {
    final provider = _routeProvider;
    if (provider == null) {
      return route;
    }

    final collected = provider.getCollectedCount(route.id);
    final status = bins.isNotEmpty && collected >= bins.length
        ? RouteStatus.completed
        : RouteStatus.highPriority;

    return route.copyWith(
      progress: collected,
      totalBins: bins.length,
      bins: bins.length,
      status: status,
    );
  }

  List<BinCollectionStatus> _buildDisplayStatuses(
    RouteData route,
    List<BinData> bins,
  ) {
    final provider = _routeProvider;
    if (provider == null) {
      return List.filled(bins.length, BinCollectionStatus.pending);
    }

    final resolvedStatuses = bins.map((bin) {
      final binId = _extractBinId(bin);
      if (binId == null) {
        return BinCollectionStatus.pending;
      }
      return provider.getBinStatus(route.id, binId);
    }).toList();

    final nextPendingIndex = resolvedStatuses.indexOf(
      BinCollectionStatus.pending,
    );
    if (nextPendingIndex != -1) {
      resolvedStatuses[nextPendingIndex] = BinCollectionStatus.collecting;
    }

    return resolvedStatuses;
  }

  Map<int, DateTime> _buildDisplayTimestamps(
    RouteData route,
    List<BinData> bins,
  ) {
    final provider = _routeProvider;
    if (provider == null) {
      return {};
    }

    final timestamps = <int, DateTime>{};
    for (int index = 0; index < bins.length; index++) {
      final binId = _extractBinId(bins[index]);
      if (binId == null) {
        continue;
      }
      final timestamp = provider.getBinTimestamp(route.id, binId);
      if (timestamp != null) {
        timestamps[index] = timestamp;
      }
    }
    return timestamps;
  }

  int? _extractBinId(BinData bin) {
    final raw = bin.id.trim();
    final numeric = raw.startsWith('BIN-') ? raw.substring(4) : raw;
    return int.tryParse(numeric);
  }
}
