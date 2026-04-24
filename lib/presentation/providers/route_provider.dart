import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/data/models/route_model.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

/// RouteProvider manages real-time route data from WebSocket updates
class RouteProvider extends ChangeNotifier {
  final WebSocketProvider webSocketProvider;
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080',
  );

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
  StreamSubscription<WebSocketMessage<Map<String, dynamic>>>?
  _messageSubscription;

  static const Duration _binCollectionAckTimeout = Duration(seconds: 5);

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
      final timestamps = _binTimestampsBySession.putIfAbsent(sessionId, () => {});
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
    if (_reportedCompletedRoutes.contains(sessionId)) {
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

    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/bincollectors/$userId/route-completion'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sessionId': sessionId,
            'assignedBins': assignedBins,
            'collectedBins': collectedBins,
            'missedBins': missedBins,
            'durationSeconds': durationSeconds,
            'completedAt': now.toIso8601String(),
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to report route completion (status ${response.statusCode}).',
      );
    }

    _reportedCompletedRoutes.add(sessionId);
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
    if (!webSocketProvider.isAuthenticated) {
      throw Exception('WebSocket is not connected/authenticated.');
    }

    final requestSessionId = sessionId ?? _lastOptimizedSessionId;

    webSocketProvider.sendMessage(
      type: 'ROUTE_OPTIMIZE',
      userId: userId,
      payload: {
        if (requestSessionId != null && requestSessionId.isNotEmpty)
          'sessionId': requestSessionId,
        'userId': userId,
        'vehicleCount': vehicleCount,
        'vehicleCapacities': vehicleCapacities,
        'depotLat': depotLat,
        'depotLng': depotLng,
        'selectedBinIds': selectedBinIds,
      },
    );

    if (requestSessionId != null && requestSessionId.isNotEmpty) {
      _lastOptimizedSessionId = requestSessionId;
    }
  }

  Future<void> reportBinCollected({
    required int userId,
    required String sessionId,
    required int binId,
    String priority = 'MEDIUM',
    double basePoints = 10.0,
  }) async {
    if (webSocketProvider.isAuthenticated) {
      for (int attempt = 0; attempt < 2; attempt++) {
        final ackFuture = _waitForBinCollectionAckOrProgress(
          userId: userId,
          binId: binId,
        );

        webSocketProvider.sendMessage(
          type: 'BIN_COLLECTED',
          userId: userId,
          payload: {
            'userId': userId,
            'sessionId': sessionId,
            'binId': binId,
            'priority': priority,
            'basePoints': basePoints,
          },
        );

        final ackState = await ackFuture;
        if (ackState == _BinCollectionAckState.acked) {
          return;
        }

        if (ackState == _BinCollectionAckState.authRace && attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 700));
          continue;
        }

        break;
      }

      debugPrint(
        'BIN_COLLECTION_ACK not received for bin $binId. Falling back to HTTP reporting.',
      );
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/api/bincollectors/$userId/collect-bin'),
          headers: {'Content-Type': 'application/json'},
          body:
              '{"binId":$binId,"priority":"$priority","basePoints":$basePoints}',
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final responseBody = response.body;
      throw Exception(
        'Failed to report collection (status ${response.statusCode}): $responseBody',
      );
    }

    debugPrint(
      'WebSocket unavailable. Collection reported over HTTP fallback for bin $binId.',
    );
  }

  Future<_BinCollectionAckState> _waitForBinCollectionAckOrProgress({
    required int userId,
    required int binId,
  }) async {
    final completer = Completer<_BinCollectionAckState>();
    StreamSubscription<WebSocketMessage<Map<String, dynamic>>>? subscription;
    Timer? timeout;

    void finish(_BinCollectionAckState value) {
      timeout?.cancel();
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    timeout = Timer(_binCollectionAckTimeout, () => finish(_BinCollectionAckState.failed));

    subscription = webSocketProvider.messageStream.listen((message) {
      if (message.type == 'BIN_COLLECTION_ACK') {
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

        final ackUserId = toInt(payload['userId']);
        final ackBinId = toInt(payload['binId']);
        if (ackUserId == userId && ackBinId == binId) {
          finish(_BinCollectionAckState.acked);
        }
      }

      if (message.type == 'TASK_PROGRESS_UPDATE') {
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

        final updateUserId = toInt(payload['userId']);
        final updateBinId = toInt(payload['binId']);
        if (updateUserId == userId && updateBinId == binId) {
          finish(_BinCollectionAckState.acked);
        }
      }

      if (message.type == 'ERROR') {
        final payload = message.payload;
        final errorText = (message.error ?? payload?['error']?.toString() ?? '')
            .toLowerCase();
        if (errorText.contains('not authenticated') ||
            errorText.contains('unable to resolve authenticated user')) {
          finish(_BinCollectionAckState.authRace);
          return;
        }
        if (errorText.contains('bin collection') ||
            errorText.contains('collector not found') ||
            errorText.contains('bin_collected')) {
          finish(_BinCollectionAckState.failed);
        }
      }
    });

    final result = await completer.future;
    return result;
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

enum _BinCollectionAckState { acked, authRace, failed }

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
