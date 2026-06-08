import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:garbo_swms/core/map/silent_network_tile_provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/route_model.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:garbo_swms/presentation/providers/route_provider.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/bottom_navigation.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';

class CollectionTeamMap extends StatefulWidget {
  final String? initialSessionId;
  final bool autoStartNavigation;

  const CollectionTeamMap({
    super.key,
    this.initialSessionId,
    this.autoStartNavigation = false,
  });

  @override
  State<CollectionTeamMap> createState() => CollectionTeamMapState();
}

class CollectionTeamMapState extends State<CollectionTeamMap> {
  final MapController mapController = MapController();
  static const LatLng fallbackCenter = LatLng(6.9271, 79.8612);
  static const double _routeDeviationThresholdMeters = 120.0;
  static const List<Color> _routePalette = [
    AppColors.blue500,
    AppColors.blue700,
    AppColors.orange200,
    AppColors.orange600,
    AppColors.orange500,
    AppColors.purple500,
    AppColors.purple600,
  ];

  StreamSubscription<Position>? _positionSubscription;
  LatLng? _currentUserLocation;
  LatLng? _previousUserLocation;
  double _currentHeadingDegrees = 0;
  String _locationStatus = 'Waiting for location permission...';
  String? _selectedSessionId;
  bool _isNavigating = false;
  bool _followCamera = true;
  final Map<String, List<LatLng>> _roadPolylineCache = {};
  final Set<String> _loadingRoadPolylineKeys = <String>{};
  String _lastRoadGeometrySignature = '';

  bool _isSameDay(DateTime value, DateTime reference) {
    return value.year == reference.year &&
        value.month == reference.month &&
        value.day == reference.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.initialSessionId;
    _isNavigating = widget.autoStartNavigation;
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final today = DateTime.now();
    final sessions = routeProvider.routeHistory
        .where((session) => _isSameDay(session.generatedAt, today))
        .toList(growable: false);
    final requestedSessionId =
        routeProvider.activeNavigationSessionId ??
        _selectedSessionId ??
        widget.initialSessionId;
    final hasSelected =
        requestedSessionId != null &&
        sessions.any((session) => session.sessionId == requestedSessionId);
    final selectedSessionId = hasSelected ? requestedSessionId : null;
    final mapData = _buildMapData(sessions, selectedSessionId, routeProvider);
    final trackingState = _buildTrackingState(mapData);
    _scheduleRoadGeometryFetch(sessions);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          const HeaderReduced(),
          Expanded(
            child: Stack(
              children: [
                _buildMap(mapData, trackingState),
                _buildMapOverlay(mapData, trackingState),
              ],
            ),
          ),
          _buildTrackingBanner(mapData, trackingState),
          _buildRouteStats(mapData),
          _buildStartNavigationButton(mapData),
        ],
      ),
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 2),
    );
  }

  Widget _buildMap(_JourneyMapData mapData, _RouteTrackingState trackingState) {
    final selectedPoints = mapData.selectedRoutePoints;
    final selectedRouteColor = mapData.selectedRouteColor ?? AppColors.blue500;
    final nearestIndex = _nearestRoutePointIndex(
      trackingState.currentLocation,
      selectedPoints,
    );
    final completedPoints = nearestIndex <= 0
        ? const <LatLng>[]
        : selectedPoints.sublist(0, nearestIndex + 1);
    final remainingPoints =
        selectedPoints.length < 2 || nearestIndex >= selectedPoints.length - 1
        ? selectedPoints
        : selectedPoints.sublist(nearestIndex);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: mapData.center,
        initialZoom: 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.garbo.swms',
          tileProvider: SilentNetworkTileProvider(),
          maxZoom: 19,
        ),
        if (mapData.polylines.isNotEmpty)
          PolylineLayer(polylines: mapData.polylines),
        if (_isNavigating && selectedPoints.length >= 2)
          PolylineLayer(
            polylines: [
              if (completedPoints.length >= 2)
                Polyline(
                  points: completedPoints,
                  strokeWidth: 7,
                  color: AppColors.grey400.withValues(alpha: 0.95),
                ),
              Polyline(
                points: remainingPoints,
                strokeWidth: 9,
                color: selectedRouteColor.withValues(alpha: 0.95),
              ),
              Polyline(
                points: remainingPoints,
                strokeWidth: 4,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        if (mapData.markers.isNotEmpty) MarkerLayer(markers: mapData.markers),
        if (trackingState.currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: trackingState.currentLocation!,
                width: _isNavigating ? 56 : 44,
                height: _isNavigating ? 56 : 44,
                child: _isNavigating
                    ? Transform.rotate(
                        angle: _toRadians(_currentHeadingDegrees),
                        child: Container(
                          decoration: BoxDecoration(
                            color: trackingState.isOnRoute
                                ? selectedRouteColor
                                : AppColors.red500,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: trackingState.isOnRoute
                              ? AppColors.green700
                              : AppColors.red500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (trackingState.isOnRoute
                                          ? AppColors.green700
                                          : AppColors.red500)
                                      .withValues(alpha: 0.28),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
              ),
            ],
          ),
        if (mapData.totalStops == 0)
          MarkerLayer(
            markers: [
              Marker(
                point: fallbackCenter,
                width: 52,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.blue500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue500.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMapOverlay(
    _JourneyMapData mapData,
    _RouteTrackingState trackingState,
  ) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _followCamera = true;
                    });
                    final target =
                        trackingState.currentLocation ?? mapData.center;
                    mapController.move(
                      target,
                      trackingState.currentLocation != null ? 15.0 : 13.0,
                    );
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.green700,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.alt_route_rounded,
                      color: AppColors.blue500,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isNavigating ? 'Navigation Live' : 'Optimized Journey',
                      style: const TextStyle(
                        color: AppColors.blue600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isNavigating) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emerald200),
                  ),
                  child: Text(
                    _followCamera ? 'Auto-follow ON' : 'Auto-follow OFF',
                    style: const TextStyle(
                      color: AppColors.green700,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (mapData.sessions.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: mapData.sessions
                    .map((session) {
                      final selected =
                          mapData.selectedSessionId == session.sessionId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSessionId = session.sessionId;
                            });
                            context
                                .read<RouteProvider>()
                                .selectNavigationSession(
                                  session.sessionId,
                                  startNavigation: _isNavigating,
                                );
                            if (session.focusPoint != null) {
                              mapController.move(session.focusPoint!, 13.5);
                            }
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? session.color
                                    : session.color.withValues(alpha: 0.45),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: session.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'R${session.sequenceNumber}',
                                  style: TextStyle(
                                    color: selected
                                        ? session.color
                                        : AppColors.grey700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingBanner(
    _JourneyMapData mapData,
    _RouteTrackingState trackingState,
  ) {
    final hasRoute = mapData.selectedRoutePoints.length >= 2;
    final routeLabel = mapData.selectedSessionId == null
        ? 'No route selected'
        : 'Tracking ${mapData.selectedSessionTitle ?? 'selected route'}';

    Color accentColor;
    String statusText;
    if (!trackingState.hasLocation) {
      accentColor = AppColors.orange500;
      statusText = _locationStatus;
    } else if (!hasRoute) {
      accentColor = AppColors.blue500;
      statusText =
          'Select a route to compare your live position against the path.';
    } else if (trackingState.isOnRoute) {
      accentColor = AppColors.green700;
      statusText = _isNavigating
          ? 'Navigating • ${trackingState.distanceMeters.round()} m from planned path'
          : 'On route • ${trackingState.distanceMeters.round()} m from path';
    } else {
      accentColor = AppColors.red500;
      statusText = _isNavigating
          ? 'Off planned path • ${trackingState.distanceMeters.round()} m deviation'
          : 'Off route • ${trackingState.distanceMeters.round()} m from path';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeLabel,
                  style: const TextStyle(
                    color: AppColors.grey900,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trackingState.hasLocation
                      ? 'Current location: ${trackingState.currentLocation!.latitude.toStringAsFixed(5)}, ${trackingState.currentLocation!.longitude.toStringAsFixed(5)}'
                      : statusText,
                  style: const TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trackingState.hasLocation && hasRoute)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteStats(_JourneyMapData mapData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRouteStat('${mapData.totalStops}', 'Bin stops'),
          Container(width: 1, height: 40, color: AppColors.grey200),
          _buildRouteStat('${mapData.sessions.length}', 'Routes'),
          Container(width: 1, height: 40, color: AppColors.grey200),
          _buildRouteStat(
            '${mapData.estimatedMinutes.round()} mins',
            'Est. Time',
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildStartNavigationButton(_JourneyMapData mapData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (mapData.sessions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No optimized route yet. Trigger optimize to start navigation.',
                    ),
                    backgroundColor: AppColors.orange500,
                  ),
                );
                return;
              }

              if (_isNavigating) {
                setState(() {
                  _isNavigating = false;
                });
                context.read<RouteProvider>().clearNavigationSession();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigation stopped.'),
                      backgroundColor: AppColors.grey600,
                    ),
                  );
                }
                return;
              }

              _SessionMapEntry? selectedSession;
              if (mapData.sessions.length == 1) {
                selectedSession = mapData.sessions.first;
              } else {
                selectedSession = await _showRoutePicker(mapData.sessions);
              }

              if (selectedSession == null) {
                return;
              }

              if (!mounted) {
                return;
              }

              setState(() {
                _selectedSessionId = selectedSession!.sessionId;
                _isNavigating = true;
                _followCamera = true;
              });
              final routeProvider = context.read<RouteProvider>();
              routeProvider.selectNavigationSession(
                selectedSession.sessionId,
                startNavigation: true,
              );
              routeProvider.markRouteStarted(selectedSession.sessionId);

              if (selectedSession.focusPoint != null) {
                mapController.move(selectedSession.focusPoint!, 13.7);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Navigating ${selectedSession.title} (${selectedSession.totalStops} stops).',
                    ),
                    backgroundColor: selectedSession.color,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isNavigating ? Icons.stop_circle_outlined : Icons.navigation,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  mapData.totalStops > 0
                      ? (_isNavigating ? 'End Navigation' : 'Start Navigation')
                      : 'Waiting For Route',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<_SessionMapEntry?> _showRoutePicker(
    List<_SessionMapEntry> sessions,
  ) async {
    return showModalBottomSheet<_SessionMapEntry>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Route To Navigate',
                  style: TextStyle(
                    color: AppColors.grey900,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...sessions.map((session) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.pop(context, session),
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: session.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      session.title,
                      style: const TextStyle(
                        color: AppColors.grey900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${session.totalStops} stops • ${session.estimatedMinutes} mins',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  _JourneyMapData _buildMapData(
    List<RouteSessionView> sessions,
    String? selectedSessionId,
    RouteProvider routeProvider,
  ) {
    if (sessions.isEmpty) {
      return const _JourneyMapData(
        center: fallbackCenter,
        polylines: [],
        markers: [],
        sessions: [],
        selectedSessionId: null,
        selectedSessionTitle: null,
        selectedRoutePoints: [],
        selectedRouteColor: null,
        totalStops: 0,
        estimatedMinutes: 0,
      );
    }

    final polylines = <Polyline>[];
    final markers = <Marker>[];
    final sessionEntries = <_SessionMapEntry>[];
    final allPoints = <LatLng>[];
    final selectedRoutePoints = <LatLng>[];
    Color? selectedRouteColor;
    int totalStops = 0;
    double totalMinutes = 0;
    String? selectedSessionTitle;

    final orderedSessions = [...sessions]
      ..sort(
        (left, right) => left.sequenceNumber.compareTo(right.sequenceNumber),
      );

    final effectiveSelectedSessionId =
        selectedSessionId ??
        (orderedSessions.length == 1 ? orderedSessions.first.sessionId : null);

    for (
      var sessionIndex = 0;
      sessionIndex < orderedSessions.length;
      sessionIndex++
    ) {
      final session = orderedSessions[sessionIndex];
      final routeColor = _routePalette[sessionIndex % _routePalette.length];
      final highlighted = effectiveSelectedSessionId == null
          ? orderedSessions.length == 1
          : session.sessionId == effectiveSelectedSessionId;
      if (session.sessionId == effectiveSelectedSessionId) {
        selectedRouteColor = routeColor;
      }

      LatLng? sessionFocus;

      final routeEntries = session.payload.routes.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final routeEntry in routeEntries) {
        final vehicleId = routeEntry.key;
        final route = routeEntry.value;

        final orderedStops = [...route.binSequence]
          ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
        if (orderedStops.isEmpty) {
          continue;
        }

        final points = orderedStops
            .map((stop) => LatLng(stop.lat, stop.lng))
            .toList(growable: false);

        final polylineCacheKey = _routePolylineKey(
          sessionId: session.sessionId,
          vehicleId: vehicleId,
          orderedStops: orderedStops,
        );
        final renderedPoints = _roadPolylineCache[polylineCacheKey] ?? points;

        sessionFocus ??= renderedPoints.first;
        allPoints.addAll(renderedPoints);
        if (session.sessionId == effectiveSelectedSessionId) {
          selectedRoutePoints.addAll(renderedPoints);
          selectedSessionTitle = session.title;
        }
        totalStops += orderedStops.length;
        totalMinutes += route.estimatedDurationSeconds / 60;

        polylines.add(
          Polyline(
            points: renderedPoints,
            strokeWidth: highlighted ? 7 : 4,
            color: highlighted
                ? routeColor.withValues(alpha: 0.95)
                : routeColor.withValues(alpha: 0.28),
          ),
        );

        for (final stop in orderedStops) {
          final collectionStatus = routeProvider.getBinStatus(
            session.sessionId,
            stop.binId,
          );
          final markerData = _RouteStopMarkerData(
            sessionId: session.sessionId,
            sessionTitle: session.title,
            vehicleId: vehicleId,
            stop: stop,
            collectionStatus: collectionStatus,
          );

          final markerFillColor = switch (collectionStatus) {
            BinCollectionStatus.collected => AppColors.green700,
            BinCollectionStatus.skipped => AppColors.grey500,
            _ => (highlighted ? routeColor : Colors.white),
          };
          final markerBorderColor = switch (collectionStatus) {
            BinCollectionStatus.collected => AppColors.green700,
            BinCollectionStatus.skipped => AppColors.grey500,
            _ => routeColor,
          };
          final markerTextColor = switch (collectionStatus) {
            BinCollectionStatus.collected => Colors.white,
            BinCollectionStatus.skipped => Colors.white,
            _ => (highlighted ? Colors.white : routeColor),
          };

          markers.add(
            Marker(
              point: LatLng(stop.lat, stop.lng),
              width: highlighted ? 40 : 34,
              height: highlighted ? 40 : 34,
              child: GestureDetector(
                onTap: () => _showBinDetails(markerData),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: markerFillColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: markerBorderColor,
                      width: highlighted ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${stop.stopOrder}',
                    style: TextStyle(
                      color: markerTextColor,
                      fontSize: highlighted ? 12 : 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }

      sessionEntries.add(
        _SessionMapEntry(
          sessionId: session.sessionId,
          sequenceNumber: session.sequenceNumber,
          title: session.title,
          color: routeColor,
          totalStops: session.totalStops,
          estimatedMinutes: session.estimatedMinutes,
          focusPoint: sessionFocus,
        ),
      );
    }

    return _JourneyMapData(
      center: allPoints.isNotEmpty ? allPoints.first : fallbackCenter,
      polylines: polylines,
      markers: markers,
      sessions: sessionEntries,
      selectedSessionId: effectiveSelectedSessionId,
      selectedSessionTitle: selectedSessionTitle,
      selectedRoutePoints: selectedRoutePoints,
      selectedRouteColor: selectedRouteColor,
      totalStops: totalStops,
      estimatedMinutes: totalMinutes,
    );
  }

  void _scheduleRoadGeometryFetch(List<RouteSessionView> sessions) {
    final signature = sessions
        .map(
          (session) =>
              '${session.sessionId}:${session.generatedAt.millisecondsSinceEpoch}',
        )
        .join('|');

    if (signature == _lastRoadGeometrySignature) {
      return;
    }

    _lastRoadGeometrySignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primeRoadGeometryCache(sessions);
    });
  }

  Future<void> _primeRoadGeometryCache(List<RouteSessionView> sessions) async {
    for (final session in sessions) {
      final routeEntries = session.payload.routes.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final routeEntry in routeEntries) {
        final vehicleId = routeEntry.key;
        final route = routeEntry.value;
        final orderedStops = [...route.binSequence]
          ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

        if (orderedStops.length < 2) {
          continue;
        }

        final cacheKey = _routePolylineKey(
          sessionId: session.sessionId,
          vehicleId: vehicleId,
          orderedStops: orderedStops,
        );
        if (_roadPolylineCache.containsKey(cacheKey) ||
            _loadingRoadPolylineKeys.contains(cacheKey)) {
          continue;
        }

        _loadingRoadPolylineKeys.add(cacheKey);

        try {
          final waypoints = orderedStops
              .map((stop) => LatLng(stop.lat, stop.lng))
              .toList(growable: false);
          final roadPolyline = await _fetchRoadPolyline(waypoints);

          if (!mounted) {
            return;
          }

          if (roadPolyline.length >= 2) {
            setState(() {
              _roadPolylineCache[cacheKey] = roadPolyline;
            });
          }
        } catch (_) {
          // Fallback to straight polylines if remote routing cannot be fetched.
        } finally {
          _loadingRoadPolylineKeys.remove(cacheKey);
        }
      }
    }
  }

  String _routePolylineKey({
    required String sessionId,
    required int vehicleId,
    required List<BinStop> orderedStops,
  }) {
    final binsPart = orderedStops.map((stop) => stop.binId).join('-');
    return '$sessionId:$vehicleId:$binsPart';
  }

  Future<List<LatLng>> _fetchRoadPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      return waypoints;
    }

    final coordinatePath = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coordinatePath?overview=full&geometries=geojson&steps=false',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return waypoints;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = body['routes'];
    if (routes is! List || routes.isEmpty) {
      return waypoints;
    }

    final firstRoute = routes.first;
    if (firstRoute is! Map<String, dynamic>) {
      return waypoints;
    }

    final geometry = firstRoute['geometry'];
    if (geometry is! Map<String, dynamic>) {
      return waypoints;
    }

    final coordinates = geometry['coordinates'];
    if (coordinates is! List) {
      return waypoints;
    }

    final roadPoints = <LatLng>[];
    for (final item in coordinates) {
      if (item is List && item.length >= 2) {
        final lng = (item[0] as num).toDouble();
        final lat = (item[1] as num).toDouble();
        roadPoints.add(LatLng(lat, lng));
      }
    }

    return roadPoints.length >= 2 ? roadPoints : waypoints;
  }

  _RouteTrackingState _buildTrackingState(_JourneyMapData mapData) {
    final currentLocation = _currentUserLocation;
    if (currentLocation == null) {
      return _RouteTrackingState(
        hasLocation: false,
        isOnRoute: false,
        distanceMeters: 0,
        currentLocation: null,
      );
    }

    if (mapData.selectedRoutePoints.length < 2) {
      return _RouteTrackingState(
        hasLocation: true,
        isOnRoute: false,
        distanceMeters: 0,
        currentLocation: currentLocation,
      );
    }

    final distanceMeters = _distanceToPolylineMeters(
      currentLocation,
      mapData.selectedRoutePoints,
    );
    return _RouteTrackingState(
      hasLocation: true,
      isOnRoute: distanceMeters <= _routeDeviationThresholdMeters,
      distanceMeters: distanceMeters,
      currentLocation: currentLocation,
    );
  }

  Future<void> _startLocationTracking() async {
    try {
      if (!_supportsRealtimeLocation()) {
        if (mounted) {
          setState(() {
            _locationStatus =
                'Live location is not supported on this platform.';
          });
        }
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationStatus = 'Location service is disabled on this device.';
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationStatus = 'Location permission was denied.';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _locationStatus = 'Live location tracking enabled.';
        });
      }

      final settings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );

      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
            (position) {
              if (!mounted) {
                return;
              }

              final latest = LatLng(position.latitude, position.longitude);
              final previous = _currentUserLocation;

              setState(() {
                if (previous != null) {
                  _previousUserLocation = previous;
                }
                _currentHeadingDegrees = _resolveHeadingDegrees(
                  position,
                  previous,
                  latest,
                );
                _currentUserLocation = latest;
                _locationStatus = 'Live location tracking enabled.';
              });

              if (_isNavigating &&
                  _followCamera &&
                  mounted &&
                  _currentUserLocation != null) {
                mapController.move(_currentUserLocation!, 16.0);
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _locationStatus = 'Location tracking error: $error';
                });
              }
            },
          );
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _locationStatus =
              'Location plugin not registered for this run target. Please stop the app and run it again (full restart).';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Failed to start location tracking: $error';
        });
      }
    }
  }

  bool _supportsRealtimeLocation() {
    if (kIsWeb) {
      return true;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  double _distanceToPolylineMeters(LatLng point, List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return double.infinity;
    }
    if (routePoints.length == 1) {
      return Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        routePoints.first.latitude,
        routePoints.first.longitude,
      );
    }

    var minDistance = double.infinity;
    for (var i = 0; i < routePoints.length - 1; i++) {
      final segmentDistance = _distanceToSegmentMeters(
        point,
        routePoints[i],
        routePoints[i + 1],
      );
      if (segmentDistance < minDistance) {
        minDistance = segmentDistance;
      }
    }
    return minDistance;
  }

  double _distanceToSegmentMeters(LatLng point, LatLng start, LatLng end) {
    const earthRadiusMeters = 6371000.0;

    final pointLat = _toRadians(point.latitude);
    final pointLng = _toRadians(point.longitude);
    final startLat = _toRadians(start.latitude);
    final startLng = _toRadians(start.longitude);
    final endLat = _toRadians(end.latitude);
    final endLng = _toRadians(end.longitude);

    final x1 =
        (startLng - pointLng) *
        math.cos((startLat + pointLat) / 2) *
        earthRadiusMeters;
    final y1 = (startLat - pointLat) * earthRadiusMeters;
    final x2 =
        (endLng - pointLng) *
        math.cos((endLat + pointLat) / 2) *
        earthRadiusMeters;
    final y2 = (endLat - pointLat) * earthRadiusMeters;

    final dx = x2 - x1;
    final dy = y2 - y1;
    final lengthSquared = dx * dx + dy * dy;
    if (lengthSquared == 0) {
      return math.sqrt(x1 * x1 + y1 * y1);
    }

    final projection = ((-x1) * dx + (-y1) * dy) / lengthSquared;
    final clampedProjection = projection.clamp(0.0, 1.0);
    final closestX = x1 + clampedProjection * dx;
    final closestY = y1 + clampedProjection * dy;

    return math.sqrt(closestX * closestX + closestY * closestY);
  }

  int _nearestRoutePointIndex(LatLng? point, List<LatLng> routePoints) {
    if (point == null || routePoints.isEmpty) {
      return 0;
    }
    var nearestIndex = 0;
    var nearestDistance = double.infinity;
    for (var i = 0; i < routePoints.length; i++) {
      final candidate = routePoints[i];
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        candidate.latitude,
        candidate.longitude,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  double _resolveHeadingDegrees(
    Position position,
    LatLng? previous,
    LatLng latest,
  ) {
    if (position.heading.isFinite && position.heading > 0) {
      return position.heading;
    }
    final start = previous ?? _previousUserLocation;
    if (start == null) {
      return _currentHeadingDegrees;
    }
    return _bearingDegrees(start, latest);
  }

  double _bearingDegrees(LatLng start, LatLng end) {
    final startLat = _toRadians(start.latitude);
    final startLng = _toRadians(start.longitude);
    final endLat = _toRadians(end.latitude);
    final endLng = _toRadians(end.longitude);

    final y = math.sin(endLng - startLng) * math.cos(endLat);
    final x =
        math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(endLng - startLng);
    final bearingRadians = math.atan2(y, x);
    return (bearingRadians * 180 / math.pi + 360) % 360;
  }

  double _toRadians(double value) => value * (math.pi / 180.0);

  void _showBinDetails(_RouteStopMarkerData markerData) {
    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bin ${markerData.stop.binId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${markerData.vehicleId}'),
            const SizedBox(height: 8),
            Text('Route: ${markerData.sessionTitle}'),
            const SizedBox(height: 8),
            Text('Stop order: ${markerData.stop.stopOrder}'),
            const SizedBox(height: 8),
            Text(
              'Location: ${markerData.stop.lat.toStringAsFixed(4)}, ${markerData.stop.lng.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 8),
            Text('Status: ${_labelForStatus(markerData.collectionStatus)}'),
            if (markerData.stop.address != null &&
                markerData.stop.address!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Address: ${markerData.stop.address!}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'skip'),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'collect'),
            child: const Text('Collect'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    ).then((action) async {
      if (!mounted || action == null) {
        return;
      }

      final routeProvider = context.read<RouteProvider>();
      final authProvider = context.read<AuthProvider>();
      final messenger = ScaffoldMessenger.of(context);
      if (action == 'collect') {
        routeProvider.markBinCollected(
          markerData.sessionId,
          markerData.stop.binId,
        );
        final currentUserId = authProvider.currentUser?.empId;
        try {
          if (currentUserId == null || currentUserId <= 0) {
            throw StateError('Collector id is required to sync collection.');
          }

          await routeProvider.reportBinCollected(
            userId: currentUserId,
            sessionId: markerData.sessionId,
            binId: markerData.stop.binId,
          );
          try {
            await routeProvider.reportRouteCompletionIfEligible(
              userId: currentUserId,
              sessionId: markerData.sessionId,
            );
          } catch (e) {
            debugPrint('Route completion reporting skipped after collect: $e');
          }
          if (!mounted) {
            return;
          }
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Bin marked as collected.'),
              duration: Duration(seconds: 1),
              backgroundColor: AppColors.green700,
            ),
          );
        } catch (_) {
          routeProvider.markBinPending(
            markerData.sessionId,
            markerData.stop.binId,
          );
          if (!mounted) {
            return;
          }
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to report collection. Please try again.'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.red500,
            ),
          );
        }
      }

      if (action == 'skip') {
        routeProvider.markBinSkipped(
          markerData.sessionId,
          markerData.stop.binId,
        );
        final currentUserId = authProvider.currentUser?.empId;
        try {
          await routeProvider.reportBinSkipped(
            sessionId: markerData.sessionId,
            binId: markerData.stop.binId,
            userId: currentUserId,
          );
          if (currentUserId != null && currentUserId > 0) {
            await routeProvider.reportRouteCompletionIfEligible(
              userId: currentUserId,
              sessionId: markerData.sessionId,
            );
          }
        } catch (_) {
          routeProvider.markBinPending(
            markerData.sessionId,
            markerData.stop.binId,
          );
          if (!mounted) {
            return;
          }
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to skip bin. Please try again.'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.red500,
            ),
          );
          return;
        }
        if (!mounted) {
          return;
        }
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Bin marked as skipped.'),
            duration: Duration(seconds: 1),
            backgroundColor: AppColors.grey600,
          ),
        );
      }
    });
  }

  String _labelForStatus(BinCollectionStatus status) {
    return switch (status) {
      BinCollectionStatus.collected => 'Collected',
      BinCollectionStatus.skipped => 'Skipped',
      BinCollectionStatus.collecting => 'Collecting',
      BinCollectionStatus.pending => 'Pending',
    };
  }
}

class _RouteStopMarkerData {
  final String sessionId;
  final String sessionTitle;
  final int vehicleId;
  final BinStop stop;
  final BinCollectionStatus collectionStatus;

  const _RouteStopMarkerData({
    required this.sessionId,
    required this.sessionTitle,
    required this.vehicleId,
    required this.stop,
    required this.collectionStatus,
  });
}

class _SessionMapEntry {
  final String sessionId;
  final int sequenceNumber;
  final String title;
  final Color color;
  final int totalStops;
  final int estimatedMinutes;
  final LatLng? focusPoint;

  const _SessionMapEntry({
    required this.sessionId,
    required this.sequenceNumber,
    required this.title,
    required this.color,
    required this.totalStops,
    required this.estimatedMinutes,
    required this.focusPoint,
  });
}

class _JourneyMapData {
  final LatLng center;
  final List<Polyline> polylines;
  final List<Marker> markers;
  final List<_SessionMapEntry> sessions;
  final String? selectedSessionId;
  final String? selectedSessionTitle;
  final List<LatLng> selectedRoutePoints;
  final Color? selectedRouteColor;
  final int totalStops;
  final double estimatedMinutes;

  const _JourneyMapData({
    required this.center,
    required this.polylines,
    required this.markers,
    required this.sessions,
    required this.selectedSessionId,
    required this.selectedSessionTitle,
    required this.selectedRoutePoints,
    required this.selectedRouteColor,
    required this.totalStops,
    required this.estimatedMinutes,
  });
}

class _RouteTrackingState {
  final bool hasLocation;
  final bool isOnRoute;
  final double distanceMeters;
  final LatLng? currentLocation;

  const _RouteTrackingState({
    required this.hasLocation,
    required this.isOnRoute,
    required this.distanceMeters,
    required this.currentLocation,
  });
}
