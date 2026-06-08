import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/core/theme/app_decorations.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
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

  bool _isSameDay(DateTime value, DateTime reference) {
    return value.year == reference.year &&
        value.month == reference.month &&
        value.day == reference.day;
  }

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
        _routeProvider?.loadAssignedRouteForCollector(currentUserId).catchError(
          (error) {
            debugPrint('Failed to load assigned route for collector: $error');
            return null;
          },
        );
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

    final today = DateTime.now();
    final history = provider.routeHistory
        .where((session) => _isSameDay(session.generatedAt, today))
        .toList(growable: false);
    if (history.isEmpty) {
      if (!mounted) return;
      setState(() {
        _lastSnapshotToken = '';
        routes.clear();
        routeBinsById.clear();
        cleanupStateForRemovedRoutes(const <String>{});
      });
      return;
    }

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

      final collected = provider.getCollectedCount(routeId);
      final skipped = provider.getSkippedCount(routeId);
      final resolved = collected + skipped;
      final isComplete = session.totalStops > 0 && resolved >= session.totalStops;

      nextRoutes.add(
        RouteData(
          id: routeId,
          name: session.title,
          bins: session.totalStops,
          distance: 0,
          duration: session.estimatedMinutes,
          progress: resolved,
          totalBins: session.totalStops,
          status: isComplete ? RouteStatus.completed : RouteStatus.pending,
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
    final routeProvider = context.watch<RouteProvider>();
    final today = DateTime.now();
    final activeRoutes = routes
        .where((route) {
          final bins = getBinsForRoute(route);
          return !_isDisplayRouteCompleted(route, bins, routeProvider);
        })
        .toList(growable: false);
    final completedRoutes = routes
        .where((route) {
          final bins = getBinsForRoute(route);
          return _isDisplayRouteCompleted(route, bins, routeProvider);
        })
        .toList(growable: false);
    final pastSessions =
        routeProvider.routeHistory
            .where((session) => !_isSameDay(session.generatedAt, today))
            .toList(growable: false)
          ..sort(
            (left, right) => right.generatedAt.compareTo(left.generatedAt),
          );

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const HeaderReduced(title: 'Routes'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 96),
                  // buildSectionTitle(),
                  // const SizedBox(height: 12),
                  if (routes.isEmpty)
                    buildNoRoutesCard()
                  else ...[
                    if (activeRoutes.isNotEmpty) ...[
                      buildSubsectionTitle(
                        'Current Routes (${activeRoutes.length})',
                      ),
                      const SizedBox(height: 12),
                      ...activeRoutes.map((route) => _buildRouteCard(route)),
                    ],
                    if (completedRoutes.isNotEmpty) ...[
                      if (activeRoutes.isNotEmpty) const SizedBox(height: 8),
                      buildSubsectionTitle(
                        'Completed Today (${completedRoutes.length})',
                      ),
                      const SizedBox(height: 12),
                      ...completedRoutes.map(
                        (route) => _buildCompletedRouteSummary(
                          route,
                          routeProvider,
                        ),
                      ),
                    ],
                    if (pastSessions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      buildSubsectionTitle(
                        'Past Routes (${pastSessions.length})',
                      ),
                      const SizedBox(height: 12),
                      ...pastSessions.map(
                        (session) => _buildRouteSummaryCard(
                          session: session,
                          provider: routeProvider,
                          badgeLabel: 'TRACKING RECORD',
                          badgeColor: AppColors.grey100,
                          badgeTextColor: AppColors.grey700,
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 140),
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

  void handleSkipBin(RouteData route) async {
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

    final messenger = ScaffoldMessenger.of(context);
    provider.markBinSkipped(route.id, binId);

    try {
      final currentUserId = context.read<AuthProvider>().currentUser?.empId;
      await provider.reportBinSkipped(
        sessionId: route.id,
        binId: binId,
        userId: currentUserId,
      );

      if (currentUserId != null && currentUserId > 0) {
        await provider.reportRouteCompletionIfEligible(
          userId: currentUserId,
          sessionId: route.id,
        );
      }

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Bin skipped'),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.grey600,
          ),
        );
      }
    } catch (_) {
      provider.markBinPending(route.id, binId);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to skip bin. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.red500,
          ),
        );
      }
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
        if (updatedBinId == null) {
          throw StateError('Unable to resolve bin id for collection.');
        }

        provider.markBinCollected(route.id, updatedBinId);

        final currentUserId = authProvider.currentUser?.empId;
        if (currentUserId == null || currentUserId <= 0) {
          throw StateError('Collector id is required to sync collection.');
        }

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

  void handleUndoBin(RouteData route) async {
    final provider = _routeProvider;
    if (provider == null) {
      return;
    }
    final authProvider = context.read<AuthProvider>();

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

    final previousStatus = statuses[lastCompletedIndex];
    provider.markBinPending(route.id, binId);

    try {
      await provider.reportBinPending(
        sessionId: route.id,
        binId: binId,
        userId: authProvider.currentUser?.empId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collection undone'),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.grey600,
          ),
        );
      }
    } catch (_) {
      if (previousStatus == BinCollectionStatus.skipped) {
        provider.markBinSkipped(route.id, binId);
      } else {
        provider.markBinCollected(route.id, binId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to undo collection. Please try again.'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    }
  }

  // Widget buildSectionTitle() {
  //   return Text(
  //     'Today\'s Routes (${routes.length})',
  //     style: const TextStyle(
  //       color: AppColors.grey900,
  //       fontSize: 16,
  //       fontWeight: FontWeight.w700,
  //     ),
  //   );
  // }

  Widget buildSubsectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.titleSm.copyWith(color: AppColors.grey700),
    );
  }

  Widget _buildCompletedRouteSummary(
    RouteData route,
    RouteProvider provider,
  ) {
    RouteSessionView? session;
    for (final item in provider.routeHistory) {
      if (item.sessionId == route.id) {
        session = item;
        break;
      }
    }

    if (session != null) {
      final assignedBins = session.totalStops;
      final collectedBins = provider.getCollectedCount(session.sessionId);
      final dateLabel = _formatAssignedDateShort(session.generatedAt);
      final durationLabel = session.estimatedMinutes > 0
          ? '${session.estimatedMinutes}m'
          : _buildCompletedDurationLabel(
              session: session,
              provider: provider,
            );

      return _buildCompactRouteSummary(
        title: session.title,
        badgeLabel: 'COMPLETED',
        badgeColor: AppColors.emeraldLight,
        badgeTextColor: AppColors.green700,
        dateLabel: dateLabel,
        collectedBins: collectedBins,
        assignedBins: assignedBins,
        durationLabel: durationLabel,
      );
    }

    final durationLabel = route.duration > 0 ? '${route.duration}m' : '--';
    return _buildCompactRouteSummary(
      title: route.name,
      badgeLabel: 'COMPLETED',
      badgeColor: AppColors.emeraldLight,
      badgeTextColor: AppColors.green700,
      dateLabel: 'Today',
      collectedBins: route.progress,
      assignedBins: route.totalBins,
      durationLabel: durationLabel,
    );
  }

  Widget _buildRouteSummaryCard({
    required RouteSessionView session,
    required RouteProvider provider,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    final assignedBins = session.totalStops;
    final collectedBins = provider.getCollectedCount(session.sessionId);
    final dateLabel = _formatAssignedDateShort(session.generatedAt);
    final durationLabel = session.estimatedMinutes > 0
        ? '${session.estimatedMinutes}m'
        : _buildCompletedDurationLabel(session: session, provider: provider);

    return _buildCompactRouteSummary(
      title: session.title,
      badgeLabel: badgeLabel,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      dateLabel: dateLabel,
      collectedBins: collectedBins,
      assignedBins: assignedBins,
      durationLabel: durationLabel,
    );
  }

  Widget _buildCompactRouteSummary({
    required String title,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeTextColor,
    required String dateLabel,
    required int collectedBins,
    required int assignedBins,
    required String durationLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTypography.overline.copyWith(
                      color: badgeTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.grey900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$dateLabel · $collectedBins/$assignedBins bins · $durationLabel',
              style: AppTypography.overline.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoRoutesCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Text(
        'No routes assigned for today yet.',
        style: AppTypography.labelMd.copyWith(
          color: AppColors.grey700,
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
    final skipped = provider.getSkippedCount(route.id);
    final resolved = collected + skipped;
    final isComplete =
        bins.isNotEmpty &&
        (resolved >= bins.length || provider.isRouteCompleted(route.id));

    return route.copyWith(
      progress: resolved,
      totalBins: bins.length,
      bins: bins.length,
      status: isComplete ? RouteStatus.completed : RouteStatus.pending,
    );
  }

  bool _isDisplayRouteCompleted(
    RouteData route,
    List<BinData> bins,
    RouteProvider provider,
  ) {
    if (bins.isEmpty) {
      return false;
    }
    final collected = provider.getCollectedCount(route.id);
    final skipped = provider.getSkippedCount(route.id);
    return (collected + skipped) >= bins.length ||
        provider.isRouteCompleted(route.id);
  }

  Widget _buildRouteCard(RouteData route) {
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
          expandedRoutes[route.id] = !(expandedRoutes[route.id] ?? false);
        }),
        onStartRoute: () => handleStartRoute(route),
        onNavigate: () => handleNavigate(route),
        onCollectNext: () => handleCollectNext(route),
        onSkipBin: () => handleSkipBin(route),
        onUndoBin: () => handleUndoBin(route),
      ),
    );
  }

  String _formatAssignedDateShort(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  String _buildCompletedDurationLabel({
    required RouteSessionView session,
    required RouteProvider provider,
  }) {
    final timestamps =
        session.stops
            .map(
              (stop) => provider.getBinTimestamp(session.sessionId, stop.binId),
            )
            .whereType<DateTime>()
            .toList(growable: false)
          ..sort();

    if (timestamps.length >= 2) {
      final duration = timestamps.last.difference(timestamps.first);
      final minutes = duration.inMinutes;
      if (minutes > 0) {
        return '${minutes}m';
      }
      final seconds = duration.inSeconds;
      if (seconds > 0) {
        return '${seconds}s';
      }
    }

    if (session.estimatedMinutes > 0) {
      return '${session.estimatedMinutes}m';
    }

    return '--';
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
