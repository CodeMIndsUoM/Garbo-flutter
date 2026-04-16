import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/route_model.dart';
import 'package:garbo_swms/data/models/route_snapshot_model.dart';
import 'package:garbo_swms/data/sources/remote/route_socket_client.dart';
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
  late final RouteSocketClient routeSocketClient;
  late final String backendBaseUrl;
  String? routeStreamMessage;
  RouteSnapshot? latestSnapshot;
  String? latestRoutePayload;

  final Map<String, bool> expandedRoutes = {};

  final Set<String> startedRoutes = {};

  final Map<String, List<BinCollectionStatus>> binStatuses = {};

  final Map<String, Map<int, DateTime>> collectedTimestamps = {};

  final Map<String, List<BinData>> routeBinsById = {};

  final List<RouteData> routes = [];

  @override
  void initState() {
    super.initState();
    backendBaseUrl = resolveBackendBaseUrl();
    routeSocketClient = RouteSocketClient(
      backendBaseUrl: backendBaseUrl,
      userId: 42,
      authToken: null,
    );
    startRouteSocket();
  }

  String resolveBackendBaseUrl() {
    const overrideUrl = String.fromEnvironment('BACKEND_URL');
    if (overrideUrl.isNotEmpty) return overrideUrl;

    if (kIsWeb) return 'http://localhost:8080';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      default:
        return 'http://localhost:8080';
    }
  }

  void startRouteSocket() {
    final wsUrl = routeSocketClient.buildWsUrl(backendBaseUrl);
    routeSocketClient.start(
      onConnected: () {
        if (!mounted) return;
        setState(() {
          routeStreamMessage = 'Connected to route stream ($wsUrl)';
        });
      },
      onProcessing: (snapshot) {
        if (!mounted) return;
        setState(() {
          updateLatestSnapshot(snapshot);
          routeStreamMessage =
              'Optimizing route v${snapshot.version} (${snapshot.trigger ?? 'update'})';
        });
      },
      onReady: (snapshot) {
        if (!mounted) return;
        setState(() {
          updateLatestSnapshot(snapshot);
          routeStreamMessage =
              'Route update ready (v${snapshot.version}). Added: ${snapshot.addedBinIds.length}, Removed: ${snapshot.removedBinIds.length}';
        });
      },
      onError: (snapshot) {
        if (!mounted) return;
        setState(() {
          updateLatestSnapshot(snapshot);
          routeStreamMessage = snapshot.message ?? 'Route stream error';
        });
      },
      onSocketError: (error) {
        if (!mounted) return;
        setState(() {
          routeStreamMessage =
              'Socket error: $error | URL: $wsUrl | Use --dart-define=BACKEND_URL=http://<your-host>:8080 if needed';
        });
      },
      onDisconnected: () {
        if (!mounted) return;
        setState(() {
          routeStreamMessage = 'Disconnected from route stream';
        });
      },
    );
  }

  @override
  void dispose() {
    routeSocketClient.stop();
    super.dispose();
  }

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
                  if (routeStreamMessage != null) ...[
                    const SizedBox(height: 12),
                    buildRouteStreamBanner(),
                  ],
                  if (latestSnapshot != null) ...[
                    const SizedBox(height: 12),
                    buildLatestSocketDataCard(),
                  ],
                  const SizedBox(height: 12),
                  if (routes.isEmpty)
                    buildNoRoutesCard()
                  else
                    ...routes.map(
                      (route) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RouteCard(
                          route: route,
                          isExpanded: expandedRoutes[route.id] ?? false,
                          isStarted: startedRoutes.contains(route.id),
                          bins: getBinsForRoute(route),
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
    final bins = getBinsForRoute(route);
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
      final bins = getBinsForRoute(route);
      final statuses = binStatuses[route.id];
      if (statuses == null) return;

      final collectingIndex = statuses.indexOf(BinCollectionStatus.collecting);
      if (collectingIndex == -1) return;
      if (collectingIndex >= bins.length) return;

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

  Widget buildRouteStreamBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blue500.withValues(alpha: 0.18)),
      ),
      child: Text(
        routeStreamMessage!,
        style: const TextStyle(
          color: AppColors.blue500,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void updateLatestSnapshot(RouteSnapshot snapshot) {
    latestSnapshot = snapshot;
    syncRoutesFromSnapshot(snapshot);

    try {
      latestRoutePayload = const JsonEncoder.withIndent(
        '  ',
      ).convert(snapshot.route);
    } catch (_) {
      latestRoutePayload = snapshot.route?.toString() ?? 'null';
    }

    debugPrint(
      'Route socket payload v${snapshot.version}: $latestRoutePayload',
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
        'No routes available yet. Waiting for websocket updates.',
        style: TextStyle(
          color: AppColors.grey700,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildLatestSocketDataCard() {
    final snapshot = latestSnapshot!;
    final payloadPreview = latestRoutePayload ?? 'No route payload';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Socket Data',
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'version: ${snapshot.version} | status: ${snapshot.status} | session: ${snapshot.sessionId}',
            style: const TextStyle(
              color: AppColors.grey700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'addedBinIds: ${snapshot.addedBinIds} | removedBinIds: ${snapshot.removedBinIds}',
            style: const TextStyle(color: AppColors.grey700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            payloadPreview,
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.grey900,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  List<BinData> getBinsForRoute(RouteData route) {
    return routeBinsById[route.id] ?? const [];
  }

  void syncRoutesFromSnapshot(RouteSnapshot snapshot) {
    final routeMaps = extractRouteMaps(snapshot.route);
    final mappedRoutes = <RouteData>[];
    final mappedBins = <String, List<BinData>>{};

    for (int i = 0; i < routeMaps.length; i++) {
      final rawRoute = routeMaps[i];
      final routeData = mapRouteData(rawRoute, snapshot, i);
      final bins = mapBinsForRoute(rawRoute, snapshot, routeData.id);
      mappedRoutes.add(
        routeData.copyWith(bins: bins.length, totalBins: bins.length),
      );
      mappedBins[routeData.id] = bins;
    }

    routes
      ..clear()
      ..addAll(mappedRoutes);
    routeBinsById
      ..clear()
      ..addAll(mappedBins);

    cleanupStateForRemovedRoutes(routes.map((r) => r.id).toSet());
    syncBinStatusLengths();
  }

  List<Map<String, dynamic>> extractRouteMaps(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map(castToStringMap)
          .toList(growable: false);
    }

    if (payload is! Map) return const [];

    final root = castToStringMap(payload);
    final listCandidates = [
      root['routes'],
      root['routeList'],
      root['items'],
      root['data'],
      root['result'],
    ];

    for (final candidate in listCandidates) {
      if (candidate is List) {
        final mapped = candidate
            .whereType<Map>()
            .map(castToStringMap)
            .toList(growable: false);
        if (mapped.isNotEmpty) return mapped;
      }
    }

    final nestedRoute = root['route'];
    if (nestedRoute is Map) {
      return [castToStringMap(nestedRoute)];
    }

    return [root];
  }

  RouteData mapRouteData(
    Map<String, dynamic> rawRoute,
    RouteSnapshot snapshot,
    int index,
  ) {
    final routeId = firstString(rawRoute, const [
      'routeId',
      'id',
      'route_id',
      'routeCode',
      'code',
    ]);
    final routeName = firstString(rawRoute, const [
      'routeName',
      'name',
      'title',
      'label',
    ]);

    final bins = mapBinsForRoute(
      rawRoute,
      snapshot,
      routeId ?? 'route-${index + 1}',
    );
    final progress =
        firstInt(rawRoute, const [
          'progress',
          'completedBins',
          'collectedBins',
          'completed',
        ]) ??
        0;
    final statusText = firstString(rawRoute, const [
      'status',
      'routeStatus',
      'priority',
    ])?.toLowerCase();

    final status = resolveRouteStatus(
      statusText: statusText,
      progress: progress,
      totalBins: bins.length,
      urgentBins: bins.where((b) => b.isUrgent).length,
    );

    return RouteData(
      id: routeId ?? 'route-${index + 1}',
      name: routeName ?? 'Route ${index + 1}',
      bins: bins.length,
      distance:
          firstDouble(rawRoute, const ['distance', 'distanceKm', 'km']) ?? 0,
      duration:
          firstInt(rawRoute, const [
            'duration',
            'durationMinutes',
            'etaMinutes',
          ]) ??
          0,
      progress: progress.clamp(0, bins.length),
      totalBins: bins.length,
      status: status,
    );
  }

  List<BinData> mapBinsForRoute(
    Map<String, dynamic> rawRoute,
    RouteSnapshot snapshot,
    String routeId,
  ) {
    final rawBins = firstList(rawRoute, const [
      'bins',
      'binList',
      'stops',
      'waypoints',
      'selectedBins',
    ]);

    if (rawBins.isNotEmpty) {
      final bins = <BinData>[];
      for (int i = 0; i < rawBins.length; i++) {
        final candidate = rawBins[i];
        if (candidate is! Map) continue;
        bins.add(
          mapBinData(
            castToStringMap(candidate),
            snapshot: snapshot,
            index: i,
            routeId: routeId,
          ),
        );
      }
      return bins;
    }

    if (snapshot.selectedBinIds.isEmpty) return const [];

    return snapshot.selectedBinIds
        .asMap()
        .entries
        .map(
          (entry) => BinData(
            id: entry.value.toString(),
            name: 'Bin ${entry.value}',
            address: 'Address not available',
            distance: 0,
            duration: 0,
            fillStatus: BinFillStatus.half,
            isUrgent: snapshot.addedBinIds.contains(entry.value),
          ),
        )
        .toList(growable: false);
  }

  BinData mapBinData(
    Map<String, dynamic> rawBin, {
    required RouteSnapshot snapshot,
    required int index,
    required String routeId,
  }) {
    final binId =
        firstString(rawBin, const ['binId', 'id', 'bin_id']) ??
        '$routeId-bin-${index + 1}';
    final fillRatio = firstDouble(rawBin, const [
      'fillPercentage',
      'fillRatio',
    ]);
    final fillLevel = firstString(rawBin, const [
      'fillStatus',
      'fillLevel',
      'level',
    ])?.toLowerCase();
    final isUrgent =
        firstBool(rawBin, const ['isUrgent', 'urgent']) ??
        (fillRatio != null ? fillRatio >= 80 : false) ||
            snapshot.addedBinIds.contains(int.tryParse(binId));

    final fillStatus =
        fillLevel == 'full' || (fillRatio != null && fillRatio >= 80)
        ? BinFillStatus.full
        : BinFillStatus.half;

    return BinData(
      id: binId,
      name:
          firstString(rawBin, const ['binName', 'name', 'title']) ??
          'Bin ${index + 1}',
      address:
          firstString(rawBin, const ['address', 'location', 'addressLine']) ??
          'Address not available',
      distance: firstDouble(rawBin, const ['distance', 'distanceKm']) ?? 0,
      duration: firstInt(rawBin, const ['duration', 'eta', 'etaMinutes']) ?? 0,
      fillStatus: fillStatus,
      isUrgent: isUrgent,
      nextDistance: firstDouble(rawBin, const [
        'nextDistance',
        'nextDistanceKm',
      ]),
      nextEta: firstInt(rawBin, const ['nextEta', 'nextEtaMinutes']),
    );
  }

  RouteStatus resolveRouteStatus({
    required String? statusText,
    required int progress,
    required int totalBins,
    required int urgentBins,
  }) {
    if (totalBins > 0 && progress >= totalBins) {
      return RouteStatus.completed;
    }

    if (statusText == 'completed' || statusText == 'done') {
      return RouteStatus.completed;
    }

    if (statusText == 'high' ||
        statusText == 'high_priority' ||
        statusText == 'urgent' ||
        urgentBins > 0) {
      return RouteStatus.highPriority;
    }

    return RouteStatus.pending;
  }

  void cleanupStateForRemovedRoutes(Set<String> activeRouteIds) {
    expandedRoutes.removeWhere(
      (routeId, _) => !activeRouteIds.contains(routeId),
    );
    startedRoutes.removeWhere((routeId) => !activeRouteIds.contains(routeId));
    binStatuses.removeWhere((routeId, _) => !activeRouteIds.contains(routeId));
    collectedTimestamps.removeWhere(
      (routeId, _) => !activeRouteIds.contains(routeId),
    );
  }

  void syncBinStatusLengths() {
    for (final route in routes) {
      final statuses = binStatuses[route.id];
      if (statuses == null) continue;
      if (statuses.length == route.totalBins) continue;

      if (statuses.length > route.totalBins) {
        binStatuses[route.id] = statuses
            .take(route.totalBins)
            .toList(growable: false);
      } else {
        final updated = [...statuses];
        updated.addAll(
          List.generate(
            route.totalBins - statuses.length,
            (_) => BinCollectionStatus.pending,
          ),
        );
        binStatuses[route.id] = updated;
      }
    }
  }

  Map<String, dynamic> castToStringMap(Map map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }

  String? firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  int? firstInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value == null) continue;
      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  double? firstDouble(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value == null) continue;
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  bool? firstBool(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) return value;
      if (value == null) continue;
      final text = value.toString().toLowerCase();
      if (text == 'true' || text == '1') return true;
      if (text == 'false' || text == '0') return false;
    }
    return null;
  }

  List<dynamic> firstList(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) return value;
    }
    return const [];
  }
}
