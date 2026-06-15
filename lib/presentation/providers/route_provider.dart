import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/data/models/route_model.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

/// RouteProvider manages real-time route data from WebSocket updates
class RouteProvider extends ChangeNotifier {
  final WebSocketProvider webSocketProvider;
  static const String _baseUrl = ApiConstants.baseUrl;

  RouteUpdatePayload? _currentRouteUpdate;
  List<VehicleRoute> _routes = [];
  final List<RouteSessionView> _routeHistory = [];
  String? _lastOptimizedSessionId;
  String? _activeNavigationSessionId;
  String? _errorMessage;
  int _lastUpdateTime = 0;
  final Map<String, Map<int, BinCollectionStatus>> _binStatusesBySession = {};
  final Map<String, Map<int, DateTime>> _binTimestampsBySession = {};
  final Map<String, DateTime> _routeStartedAtBySession = {};
  final Set<String> _reportedCompletedRoutes = <String>{};
  final Set<String> _pendingRouteCompletionReports = <String>{};
  final Set<int> _pendingAssignedRouteRetries = <int>{};
  final Set<String> _assignedSessionIds = <String>{};
  final Map<String, int> _sessionUpdatedAtById = <String, int>{};
  int? _boundUserId;
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _messageSubscription;

  RouteUpdatePayload? get currentRouteUpdate => _currentRouteUpdate;
  List<VehicleRoute> get routes => _routes;
  List<RouteSessionView> get routeHistory => List.unmodifiable(_routeHistory);
  String? get latestSessionId =>
      _routeHistory.isNotEmpty ? _routeHistory.last.sessionId : null;
  String? get lastOptimizedSessionId => _lastOptimizedSessionId;
  String? get activeNavigationSessionId => _activeNavigationSessionId;
  String? get errorMessage => _errorMessage;
  int get lastUpdateTime => _lastUpdateTime;

  RouteProvider(this.webSocketProvider) {
    _listenToRouteUpdates();
  }

  void bindToUser(int userId) {
    if (_boundUserId == userId) {
      return;
    }
    _boundUserId = userId;
    _resetRouteState();
    notifyListeners();
  }

  /// Listen to ROUTE_UPDATE messages from WebSocket
  void _listenToRouteUpdates() {
    _messageSubscription?.cancel();
    _messageSubscription = webSocketProvider.messageStream.listen((message) {
      if (message.type == 'ROUTE_UPDATE') {
        try {
          // Parse the route update payload
          final payload = message.payload;
          if (payload != null) {
            final routeData = RouteUpdatePayload.fromJson(payload);
            if (!_shouldAcceptRouteUpdate(routeData)) {
              return;
            }
            _currentRouteUpdate = routeData;
            _routes = routeData.routes.values.toList();
            _lastUpdateTime = routeData.updatedAt;
            _errorMessage = null;
            _lastOptimizedSessionId = routeData.sessionId;

            _upsertRouteHistory(routeData);

            debugPrint('Route update received: ${_routes.length} routes');
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing route update: $e');
          _errorMessage = 'Failed to parse route update: $e';
          notifyListeners();
        }
      } else if (message.type == 'ROUTE_OPTIMIZE_ACK') {
        try {
          final payload = message.payload;
          if (payload == null) {
            return;
          }

          final ack = RouteOptimizeAckPayload.fromJson(payload);
          if (ack.sessionId.isNotEmpty) {
            _lastOptimizedSessionId = ack.sessionId;
          }

          if ('ERROR'.toUpperCase() == ack.status.toUpperCase()) {
            _errorMessage = ack.message ?? 'Route optimization failed.';
          } else {
            _errorMessage = null;
          }

          notifyListeners();
        } catch (e) {
          debugPrint('Error parsing route optimize ack: $e');
        }
      } else if (message.type == 'ROUTE_ASSIGNED') {
        _errorMessage = null;
        notifyListeners();
        final userId = _boundUserId ?? message.userId;
        if (userId != null) {
          unawaited(loadAssignedRouteForCollector(userId));
        }
      } else if (message.type == 'BIN_COLLECTION_ACK' ||
          message.type == 'TASK_PROGRESS_UPDATE') {
        final payload = message.payload;
        if (payload == null) {
          return;
        }

        int? toInt(dynamic value) {
          if (value is int) {
            return value;
          }
          if (value is num) {
            return value.toInt();
          }
          return int.tryParse(value?.toString() ?? '');
        }

        final binId = toInt(payload['binId']);
        if (binId != null) {
          _applyRemoteCollectedBin(binId);
        }
      }
    });
  }

  void _applyRemoteCollectedBin(int binId) {
    bool changed = false;

    for (final session in _routeHistory) {
      final sessionId = session.sessionId;
      final hasBin = session.stops.any((stop) => stop.binId == binId);
      if (!hasBin) {
        continue;
      }

      final statuses = _binStatusesBySession.putIfAbsent(sessionId, () => {});
      final timestamps = _binTimestampsBySession.putIfAbsent(
        sessionId,
        () => {},
      );
      final current = statuses[binId];

      if (current != BinCollectionStatus.collected) {
        statuses[binId] = BinCollectionStatus.collected;
        timestamps[binId] = DateTime.now();
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Get bin sequence for a specific vehicle
  List<BinStop> getBinSequenceForVehicle(int vehicleId) {
    final route = _currentRouteUpdate?.routes[vehicleId];
    return route?.binSequence ?? [];
  }

  /// Get all bins in order
  List<BinStop> getAllBinsInOrder() {
    final allBins = <BinStop>[];
    for (var route in _routes) {
      allBins.addAll(route.binSequence);
    }
    // Sort by stop order
    allBins.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    return allBins;
  }

  /// Get route statistics
  RouteStatistics getRouteStatistics() {
    int totalBins = 0;
    double totalDuration = 0;

    for (var route in _routes) {
      totalBins += route.totalBins;
      totalDuration += route.estimatedDurationSeconds;
    }

    return RouteStatistics(
      totalVehicles: _currentRouteUpdate?.totalVehiclesUsed ?? 0,
      totalBins: totalBins,
      estimatedDurationMinutes: totalDuration / 60,
    );
  }

  void _upsertRouteHistory(RouteUpdatePayload payload) {
    final existingIndex = _routeHistory.indexWhere(
      (item) => item.sessionId == payload.sessionId,
    );
    final nextItem = RouteSessionView.fromPayload(payload, existingIndex + 1);

    if (existingIndex == -1) {
      _routeHistory.add(nextItem);
    } else {
      _routeHistory[existingIndex] = nextItem;
    }

    _routeHistory.sort(
      (left, right) => left.generatedAt.compareTo(right.generatedAt),
    );

    for (var index = 0; index < _routeHistory.length; index++) {
      _routeHistory[index] = _routeHistory[index].copyWith(
        sequenceNumber: index + 1,
        title: 'Route ${index + 1} - ${_routeHistory[index].shiftLabel}',
      );
      _ensureSessionTracking(_routeHistory[index]);
    }

    if (_activeNavigationSessionId != null &&
        !_routeHistory.any(
          (item) => item.sessionId == _activeNavigationSessionId,
        )) {
      _activeNavigationSessionId = null;
    }

    final activeSessionIds = _routeHistory
        .map((item) => item.sessionId)
        .toSet();
    _routeStartedAtBySession.removeWhere(
      (sessionId, _) => !activeSessionIds.contains(sessionId),
    );
    _reportedCompletedRoutes.removeWhere(
      (sessionId) => !activeSessionIds.contains(sessionId),
    );
  }

  void _ensureSessionTracking(RouteSessionView session) {
    final statuses = _binStatusesBySession.putIfAbsent(
      session.sessionId,
      () => {},
    );
    final timestamps = _binTimestampsBySession.putIfAbsent(
      session.sessionId,
      () => {},
    );
    final validBinIds = session.stops.map((stop) => stop.binId).toSet();

    for (final stop in session.stops) {
      statuses.putIfAbsent(stop.binId, () => BinCollectionStatus.pending);
    }

    statuses.removeWhere((binId, _) => !validBinIds.contains(binId));
    timestamps.removeWhere((binId, _) => !validBinIds.contains(binId));
  }

  void selectNavigationSession(
    String sessionId, {
    bool startNavigation = true,
  }) {
    _activeNavigationSessionId = sessionId;
    if (startNavigation) {
      _routeStartedAtBySession.putIfAbsent(sessionId, () => DateTime.now());
    }
    notifyListeners();
  }

  void markRouteStarted(String sessionId) {
    _routeStartedAtBySession.putIfAbsent(sessionId, () => DateTime.now());
  }

  void clearNavigationSession() {
    if (_activeNavigationSessionId == null) {
      return;
    }
    _activeNavigationSessionId = null;
    notifyListeners();
  }

  BinCollectionStatus getBinStatus(String sessionId, int binId) {
    return _binStatusesBySession[sessionId]?[binId] ??
        BinCollectionStatus.pending;
  }

  DateTime? getBinTimestamp(String sessionId, int binId) {
    return _binTimestampsBySession[sessionId]?[binId];
  }

  void markBinCollected(String sessionId, int binId) {
    _setBinStatus(sessionId, binId, BinCollectionStatus.collected);
  }

  void markBinSkipped(String sessionId, int binId) {
    _setBinStatus(sessionId, binId, BinCollectionStatus.skipped);
  }

  void markBinPending(String sessionId, int binId) {
    _setBinStatus(sessionId, binId, BinCollectionStatus.pending);
  }

  void _setBinStatus(String sessionId, int binId, BinCollectionStatus status) {
    final sessionStatuses = _binStatusesBySession.putIfAbsent(
      sessionId,
      () => {},
    );
    final sessionTimestamps = _binTimestampsBySession.putIfAbsent(
      sessionId,
      () => {},
    );

    sessionStatuses[binId] = status;
    if (status == BinCollectionStatus.collected ||
        status == BinCollectionStatus.skipped) {
      sessionTimestamps[binId] = DateTime.now();
    } else {
      sessionTimestamps.remove(binId);
      _reportedCompletedRoutes.remove(sessionId);
    }

    notifyListeners();
  }

  bool isRouteCompleted(String sessionId) {
    final statuses = _binStatusesBySession[sessionId];
    if (statuses == null || statuses.isEmpty) {
      return false;
    }
    return statuses.values.every(
      (status) => status != BinCollectionStatus.pending,
    );
  }

  Future<void> reportRouteCompletionIfEligible({
    required int userId,
    required String sessionId,
  }) async {
    if (_reportedCompletedRoutes.contains(sessionId) ||
        _pendingRouteCompletionReports.contains(sessionId)) {
      return;
    }

    final statuses = _binStatusesBySession[sessionId];
    if (statuses == null || statuses.isEmpty) {
      return;
    }

    final assignedBins = statuses.length;
    final collectedBins = statuses.values
        .where((status) => status == BinCollectionStatus.collected)
        .length;
    final missedBins = statuses.values
        .where((status) => status == BinCollectionStatus.skipped)
        .length;

    final completed = collectedBins + missedBins;
    if (completed < assignedBins) {
      return;
    }

    final startedAt = _routeStartedAtBySession[sessionId];
    final now = DateTime.now();
    final durationSeconds = startedAt != null
        ? now.difference(startedAt).inSeconds.clamp(0, 86400)
        : 0;

    _pendingRouteCompletionReports.add(sessionId);
    try {
      final headers = await _buildAuthHeaders();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/bincollectors/$userId/route-completion'),
            headers: headers,
            body: jsonEncode({
              'sessionId': sessionId,
              'assignedBins': assignedBins,
              'collectedBins': collectedBins,
              'missedBins': missedBins,
              'durationSeconds': durationSeconds,
              'completedAt': now.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        debugPrint(
          'Route completion sync failed for session $sessionId: ${response.statusCode} ${response.body}',
        );
        _scheduleRouteCompletionRetry(userId: userId, sessionId: sessionId);
        return;
      }

      _reportedCompletedRoutes.add(sessionId);
    } on TimeoutException catch (e) {
      debugPrint('Route completion sync timed out for session $sessionId: $e');
      _scheduleRouteCompletionRetry(userId: userId, sessionId: sessionId);
    } catch (e) {
      debugPrint('Route completion sync threw for session $sessionId: $e');
      _scheduleRouteCompletionRetry(userId: userId, sessionId: sessionId);
    } finally {
      _pendingRouteCompletionReports.remove(sessionId);
    }
  }

  void _scheduleRouteCompletionRetry({
    required int userId,
    required String sessionId,
  }) {
    Future<void>.delayed(const Duration(seconds: 2), () async {
      if (_reportedCompletedRoutes.contains(sessionId)) {
        return;
      }
      try {
        await reportRouteCompletionIfEligible(
          userId: userId,
          sessionId: sessionId,
        );
      } catch (_) {
        // Completion reporting is best-effort after route state is already persisted.
      }
    });
  }

  int getCollectedCount(String sessionId) {
    final statuses = _binStatusesBySession[sessionId];
    if (statuses == null) {
      return 0;
    }
    return statuses.values
        .where((status) => status == BinCollectionStatus.collected)
        .length;
  }

  int getSkippedCount(String sessionId) {
    final statuses = _binStatusesBySession[sessionId];
    if (statuses == null) {
      return 0;
    }
    return statuses.values
        .where((status) => status == BinCollectionStatus.skipped)
        .length;
  }

  Future<void> optimizeRoutes({
    required int userId,
    required double depotLat,
    required double depotLng,
    required int vehicleCount,
    List<int> selectedBinIds = const [],
    List<int>? vehicleCapacities,
    String? sessionId,
  }) async {
    final requestSessionId = sessionId ?? _lastOptimizedSessionId;

    final response = await http
        .post(
          Uri.parse('$_baseUrl/routes/optimize'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            if (requestSessionId != null && requestSessionId.isNotEmpty)
              'sessionId': requestSessionId,
            'userId': userId,
            'vehicleCount': vehicleCount,
            'vehicleCapacities': vehicleCapacities,
            'depotLat': depotLat,
            'depotLng': depotLng,
            'selectedBinIds': selectedBinIds,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to optimize route: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final routeData = _routeUpdateFromSnapshot(decoded);
      if (routeData != null) {
        _applyRouteUpdatePayload(routeData);
        _lastOptimizedSessionId = routeData.sessionId;
      } else if (decoded['sessionId'] != null) {
        _lastOptimizedSessionId = decoded['sessionId'].toString();
      }
    }
  }

  Future<void> reportBinCollected({
    required int userId,
    required String sessionId,
    required int binId,
    String priority = 'MEDIUM',
    double basePoints = 10.0,
  }) async {
    final persistResponse = await http
        .patch(
          Uri.parse(
            '$_baseUrl/route-sessions/$sessionId/bins/$binId/collect?collectorId=$userId',
          ),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));

    if (persistResponse.statusCode < 200 || persistResponse.statusCode >= 300) {
      final responseBody = persistResponse.body;
      throw Exception(
        'Failed to persist collection (status ${persistResponse.statusCode}): $responseBody',
      );
    }

    // Keep collector gamification sync as best-effort after DB state is persisted.
    try {
      final headers = await _buildAuthHeaders();
      final response = await http
          .post(
            Uri.parse('$_baseUrl/bincollectors/$userId/collect-bin'),
            headers: headers,
            body: jsonEncode({
              'binId': binId,
              'priority': priority,
              'basePoints': basePoints,
              'sessionId': sessionId,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Collector realtime sync failed for session $sessionId, bin $binId: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint(
        'Collector realtime sync threw for session $sessionId, bin $binId: $e',
      );
    }
  }

  Future<void> reportBinSkipped({
    required String sessionId,
    required int binId,
    int? userId,
  }) async {
    final suffix = userId != null ? '?collectorId=$userId' : '';
    final response = await http
        .patch(
          Uri.parse(
            '$_baseUrl/route-sessions/$sessionId/bins/$binId/skip$suffix',
          ),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to persist skipped bin (status ${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> reportBinPending({
    required String sessionId,
    required int binId,
    int? userId,
  }) async {
    final suffix = userId != null ? '?collectorId=$userId' : '';
    final response = await http
        .patch(
          Uri.parse(
            '$_baseUrl/route-sessions/$sessionId/bins/$binId/pending$suffix',
          ),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to persist pending bin (status ${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<String?> loadAssignedRouteForCollector(int userId) async {
    bindToUser(userId);

    http.Response assignmentResponse;
    try {
      assignmentResponse = await http
          .get(Uri.parse('$_baseUrl/route-sessions/user/$userId/active'))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      final fallbackSessionId = _fallbackAssignedSessionIdForUser(userId);
      if (fallbackSessionId != null) {
        debugPrint(
          'Active assignment fetch timed out; using existing realtime route session $fallbackSessionId.',
        );
        return fallbackSessionId;
      }
      debugPrint(
        'Active assignment fetch timed out for user $userId; scheduling background retry.',
      );
      _scheduleAssignedRouteRetry(userId);
      return null;
    }

    if (assignmentResponse.statusCode < 200 ||
        assignmentResponse.statusCode >= 300) {
      debugPrint(
        'Failed to fetch active route assignment for user $userId (status ${assignmentResponse.statusCode}).',
      );
      _scheduleAssignedRouteRetry(userId);
      return _fallbackAssignedSessionIdForUser(userId);
    }

    final decoded = jsonDecode(assignmentResponse.body);
    List<dynamic> assignments;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      assignments = data is List ? data : const [];
    } else if (decoded is List) {
      assignments = decoded;
    } else {
      assignments = const [];
    }

    final sessionIds = <String>{};
    final nextSessionUpdatedAtById = <String, int>{};
    for (final item in assignments) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final rawSessionId = item['sessionId']?.toString().trim();
      if (rawSessionId != null && rawSessionId.isNotEmpty) {
        sessionIds.add(rawSessionId);
        final updatedAt = _toInt(item['updatedAt']);
        final createdDateRaw = item['createdDate']?.toString();
        final createdAt = createdDateRaw != null && createdDateRaw.isNotEmpty
            ? DateTime.tryParse(createdDateRaw)
            : null;
        if (createdAt != null) {
          nextSessionUpdatedAtById[rawSessionId] =
              createdAt.millisecondsSinceEpoch;
        } else if (updatedAt > 0) {
          nextSessionUpdatedAtById[rawSessionId] = updatedAt;
        }
      }
    }

    _assignedSessionIds
      ..clear()
      ..addAll(sessionIds);
    _sessionUpdatedAtById
      ..clear()
      ..addAll(nextSessionUpdatedAtById);

    if (_assignedSessionIds.isEmpty) {
      _resetRouteState(keepBoundUser: true);
      _errorMessage = null;
      notifyListeners();
      return null;
    }

    final orderedSessionIds = _assignedSessionIds.toList()..sort();
    final loadedSessionIds = <String>[];
    for (final sessionId in orderedSessionIds) {
      final loadedFromPersisted = await _loadPersistedSessionRoutes(
        sessionId: sessionId,
        userId: userId,
      );

      if (!loadedFromPersisted) {
        try {
          await _loadSessionSnapshot(sessionId: sessionId, userId: userId);
        } on TimeoutException {
          debugPrint(
            'Route session snapshot fetch timed out for session $sessionId; will retry in background.',
          );
          _scheduleAssignedRouteRetry(userId);
          continue;
        } catch (error) {
          // Stale active assignments can outlive the in-memory snapshot cache
          // after a backend restart. Skip 404s and keep trying other sessions.
          if (_isMissingSessionSnapshotError(error)) {
            continue;
          }
          rethrow;
        }
      }

      loadedSessionIds.add(sessionId);
    }

    if (loadedSessionIds.isEmpty) {
      _resetRouteState(keepBoundUser: true);
      _assignedSessionIds
        ..clear()
        ..addAll(sessionIds);
      _errorMessage = null;
      notifyListeners();
      return null;
    }

    final sessionId = loadedSessionIds.last;
    _lastOptimizedSessionId = sessionId;
    return sessionId;
  }

  void _scheduleAssignedRouteRetry(int userId) {
    if (!_pendingAssignedRouteRetries.add(userId)) {
      return;
    }

    Future<void>.delayed(const Duration(seconds: 3), () async {
      _pendingAssignedRouteRetries.remove(userId);
      if (_boundUserId != null && _boundUserId != userId) {
        return;
      }
      try {
        await loadAssignedRouteForCollector(userId);
      } catch (_) {
        // Assigned-route bootstrap is retried opportunistically in background.
      }
    });
  }

  String? _fallbackAssignedSessionIdForUser(int userId) {
    if (_boundUserId != null && _boundUserId != userId) {
      return null;
    }

    if (_routeHistory.isNotEmpty) {
      final latest = _routeHistory.last;
      _assignedSessionIds.add(latest.sessionId);
      _lastOptimizedSessionId = latest.sessionId;
      return latest.sessionId;
    }

    final currentSessionId = _currentRouteUpdate?.sessionId;
    if (currentSessionId != null && currentSessionId.isNotEmpty) {
      _assignedSessionIds.add(currentSessionId);
      _lastOptimizedSessionId = currentSessionId;
      return currentSessionId;
    }

    return null;
  }

  Future<bool> _loadPersistedSessionRoutes({
    required String sessionId,
    required int userId,
  }) async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$_baseUrl/route-sessions/$sessionId/routes'))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      debugPrint('Persisted route fetch timed out for session $sessionId.');
      return false;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return false;
    }

    final routeEntries = decoded.whereType<Map<String, dynamic>>().toList();
    if (routeEntries.isEmpty) {
      return false;
    }

    final routesMap = <int, VehicleRoute>{};
    final persistedStatuses = <int, BinCollectionStatus>{};
    final persistedTimestamps = <int, DateTime>{};

    BinCollectionStatus parseStopStatus(dynamic value) {
      final raw = value?.toString().toUpperCase().trim();
      if (raw == 'COLLECTED') {
        return BinCollectionStatus.collected;
      }
      if (raw == 'SKIPPED') {
        return BinCollectionStatus.skipped;
      }
      return BinCollectionStatus.pending;
    }

    for (var index = 0; index < routeEntries.length; index++) {
      final route = routeEntries[index];
      final vehicleKey = route['vehicleKey']?.toString() ?? '$index';
      final vehicleId = int.tryParse(vehicleKey) ?? index;
      final capacity = _toInt(route['capacity']);
      final totalBins = _toInt(route['totalBins']);
      final estimatedDurationSeconds = _toDouble(
        route['estimatedDurationSeconds'],
      );

      final rawStops = route['binStops'];
      final stopItems = rawStops is List
          ? rawStops.whereType<Map<String, dynamic>>().toList()
          : const <Map<String, dynamic>>[];
      stopItems.sort(
        (left, right) =>
            _toInt(left['stopOrder']).compareTo(_toInt(right['stopOrder'])),
      );

      for (final stop in stopItems) {
        final binId = _toInt(stop['binId']);
        final stopStatus = parseStopStatus(stop['status']);
        persistedStatuses[binId] = stopStatus;

        final collectedAtRaw = stop['collectedAt']?.toString();
        if (collectedAtRaw != null && collectedAtRaw.isNotEmpty) {
          final parsed = DateTime.tryParse(collectedAtRaw);
          if (parsed != null) {
            persistedTimestamps[binId] = parsed;
          }
        }
      }

      final stops = stopItems
          .map(
            (stop) => BinStop(
              stopOrder: _toInt(stop['stopOrder']),
              binId: _toInt(stop['binId']),
              lat: _toDouble(stop['lat']),
              lng: _toDouble(stop['lng']),
              durationFromPrevStopSeconds: _toDouble(
                stop['durationFromPrevSeconds'],
              ),
            ),
          )
          .toList(growable: false);

      routesMap[vehicleId] = VehicleRoute(
        vehicleId: vehicleId,
        capacity: capacity,
        totalBins: totalBins,
        estimatedDurationSeconds: estimatedDurationSeconds,
        binSequence: stops,
      );
    }

    _binStatusesBySession[sessionId] = persistedStatuses;
    _binTimestampsBySession[sessionId] = persistedTimestamps;

    _applyRouteUpdatePayload(
      RouteUpdatePayload(
        sessionId: sessionId,
        userId: userId,
        totalVehiclesUsed: routesMap.length,
        routes: routesMap,
        updatedAt:
            _sessionUpdatedAtById[sessionId] ??
            DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return true;
  }

  Future<void> _loadSessionSnapshot({
    required String sessionId,
    required int userId,
  }) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/route-sessions/$sessionId'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to fetch route session snapshot (status ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid route session snapshot format.');
    }

    final routeData = _routeUpdateFromSnapshot({
      ...decoded,
      'sessionId': decoded['sessionId']?.toString() ?? sessionId,
      'userId': decoded['userId'] ?? userId,
    });

    if (routeData == null) {
      throw Exception('Snapshot does not contain route data.');
    }

    _applyRouteUpdatePayload(routeData);
  }

  bool _isMissingSessionSnapshotError(Object error) {
    final message = error.toString();
    return message.contains('Failed to fetch route session snapshot') &&
        message.contains('status 404');
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  RouteUpdatePayload? _routeUpdateFromSnapshot(Map<String, dynamic> snapshot) {
    final route = snapshot['route'];
    if (route is! Map<String, dynamic>) {
      return null;
    }

    final routes = route['routes'];
    if (routes is! Map<String, dynamic>) {
      return null;
    }

    return RouteUpdatePayload.fromJson({
      'sessionId': snapshot['sessionId']?.toString() ?? '',
      'userId': snapshot['userId'] is num
          ? (snapshot['userId'] as num).toInt()
          : snapshot['userId'],
      'updatedAt': snapshot['updatedAt'] is num
          ? (snapshot['updatedAt'] as num).toInt()
          : DateTime.now().millisecondsSinceEpoch,
      'totalVehiclesUsed': route['totalVehiclesUsed'] is num
          ? (route['totalVehiclesUsed'] as num).toInt()
          : 0,
      'routes': routes,
    });
  }

  void _applyRouteUpdatePayload(RouteUpdatePayload routeData) {
    if (!_shouldAcceptRouteUpdate(routeData)) {
      return;
    }
    _currentRouteUpdate = routeData;
    _routes = routeData.routes.values.toList();
    _lastUpdateTime = routeData.updatedAt;
    _errorMessage = null;
    _upsertRouteHistory(routeData);
    notifyListeners();
  }

  bool _shouldAcceptRouteUpdate(RouteUpdatePayload routeData) {
    final expectedUser = _boundUserId;
    if (expectedUser != null) {
      final payloadUserId = routeData.userId;
      if (payloadUserId != null && payloadUserId != expectedUser) {
        return false;
      }
    }

    if (_assignedSessionIds.isNotEmpty &&
        !_assignedSessionIds.contains(routeData.sessionId)) {
      _assignedSessionIds.add(routeData.sessionId);
    }

    return true;
  }

  void _resetRouteState({bool keepBoundUser = false}) {
    _currentRouteUpdate = null;
    _routes = [];
    _routeHistory.clear();
    _lastOptimizedSessionId = null;
    _activeNavigationSessionId = null;
    _errorMessage = null;
    _lastUpdateTime = 0;
    _binStatusesBySession.clear();
    _binTimestampsBySession.clear();
    _routeStartedAtBySession.clear();
    _reportedCompletedRoutes.clear();
    _assignedSessionIds.clear();
    _sessionUpdatedAtById.clear();
    if (!keepBoundUser) {
      _boundUserId = null;
    }
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return <String, String>{
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

/// Route statistics model
class RouteStatistics {
  final int totalVehicles;
  final int totalBins;
  final double estimatedDurationMinutes;

  RouteStatistics({
    required this.totalVehicles,
    required this.totalBins,
    required this.estimatedDurationMinutes,
  });
}

class RouteSessionView {
  final String sessionId;
  final int sequenceNumber;
  final String title;
  final String shiftLabel;
  final DateTime generatedAt;
  final int totalStops;
  final int estimatedMinutes;
  final String summary;
  final List<BinStop> stops;
  final RouteUpdatePayload payload;

  const RouteSessionView({
    required this.sessionId,
    required this.sequenceNumber,
    required this.title,
    required this.shiftLabel,
    required this.generatedAt,
    required this.totalStops,
    required this.estimatedMinutes,
    required this.summary,
    required this.stops,
    required this.payload,
  });

  factory RouteSessionView.fromPayload(
    RouteUpdatePayload payload,
    int sequenceNumber,
  ) {
    final stops = <BinStop>[];
    final orderedRoutes = payload.routes.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    for (final routeEntry in orderedRoutes) {
      final orderedStops = [...routeEntry.value.binSequence]
        ..sort((left, right) => left.stopOrder.compareTo(right.stopOrder));
      stops.addAll(orderedStops);
    }

    final generatedAt = DateTime.fromMillisecondsSinceEpoch(payload.updatedAt);
    final shiftLabel = _shiftLabelFor(generatedAt);
    final title = 'Route $sequenceNumber - $shiftLabel';
    final estimatedMinutes =
        (orderedRoutes
                    .map((entry) => entry.value.estimatedDurationSeconds)
                    .fold<double>(0, (sum, duration) => sum + duration) /
                60)
            .round();

    return RouteSessionView(
      sessionId: payload.sessionId,
      sequenceNumber: sequenceNumber,
      title: title,
      shiftLabel: shiftLabel,
      generatedAt: generatedAt,
      totalStops: stops.length,
      estimatedMinutes: estimatedMinutes,
      summary: stops.isEmpty
          ? 'No stops available'
          : '${stops.length} stops • $estimatedMinutes mins',
      stops: stops,
      payload: payload,
    );
  }

  RouteSessionView copyWith({
    String? sessionId,
    int? sequenceNumber,
    String? title,
    String? shiftLabel,
    DateTime? generatedAt,
    int? totalStops,
    int? estimatedMinutes,
    String? summary,
    List<BinStop>? stops,
    RouteUpdatePayload? payload,
  }) {
    return RouteSessionView(
      sessionId: sessionId ?? this.sessionId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      title: title ?? this.title,
      shiftLabel: shiftLabel ?? this.shiftLabel,
      generatedAt: generatedAt ?? this.generatedAt,
      totalStops: totalStops ?? this.totalStops,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      summary: summary ?? this.summary,
      stops: stops ?? this.stops,
      payload: payload ?? this.payload,
    );
  }

  static String _shiftLabelFor(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) {
      return 'Morning Shift';
    }
    if (hour < 18) {
      return 'Afternoon Shift';
    }
    return 'Evening Shift';
  }
}
