import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';

/// STOMP client for GARBO real-time updates.
/// Keeps the Flutter app aligned with the dashboard's socket contract.
class WebSocketService {
  StompClient? _client;
  late StreamController<WebSocketMessage<Map<String, dynamic>>>
  _messageController;
  late StreamController<ConnectionStatus> _statusController;

  int? _userId;
  bool _isConnected = false;
  bool _isAuthenticated = false;
  bool _manualDisconnect = false;
  bool _isDisposed = false;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  final List<VoidCallback> _unsubscribeCallbacks = [];
  Completer<void>? _connectCompleter;

  /// Stream of incoming WebSocket messages
  Stream<WebSocketMessage<Map<String, dynamic>>> get messageStream =>
      _messageController.stream;

  /// Stream of connection status changes
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  /// Current connection status
  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
  ConnectionStatus get currentStatus => _currentStatus;

  WebSocketService() {
    _messageController =
        StreamController<WebSocketMessage<Map<String, dynamic>>>.broadcast();
    _statusController = StreamController<ConnectionStatus>.broadcast();
  }

  void _setStatus(ConnectionStatus statusValue) {
    if (_isDisposed || _statusController.isClosed) {
      return;
    }
    _currentStatus = statusValue;
    _statusController.add(statusValue);
  }

  /// Connect to WebSocket server
  Future<void> connect(String serverUrl, int userId) async {
    try {
      await disconnect();
      _manualDisconnect = false;
      _userId = userId;
      _isConnected = false;
      _isAuthenticated = false;

      _setStatus(ConnectionStatus.connecting);

      final wsUrl = _toSockJsUrl(serverUrl);
      debugPrint('Connecting to STOMP socket: $wsUrl');

      _connectCompleter = Completer<void>();

      _client = StompClient(
        config: StompConfig.sockJS(
          url: wsUrl,
          reconnectDelay: const Duration(seconds: 3),
          onConnect: _onStompConnect,
          onWebSocketError: _onWebSocketError,
          onWebSocketDone: _onWebSocketDone,
          onStompError: _onStompError,
        ),
      );

      _client!.activate();

      try {
        await _connectCompleter!.future.timeout(const Duration(seconds: 20));
      } on TimeoutException {
        debugPrint(
          'STOMP initial connect timed out; keeping client active for background reconnect.',
        );
        if (!_manualDisconnect) {
          _setStatus(ConnectionStatus.reconnecting);
        }
        return;
      }
    } catch (e) {
      debugPrint('STOMP connection error: $e');
      _isConnected = false;
      if (!_manualDisconnect) {
        _setStatus(ConnectionStatus.error);
      }
      rethrow;
    }
  }

  String _toSockJsUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final basePath = uri.path.endsWith('/api')
        ? uri.path.substring(0, uri.path.length - 4)
        : uri.path;
    final wsPath = '$basePath/ws'.replaceAll('//', '/');
    return uri.replace(path: wsPath).toString();
  }

  void _onStompConnect(StompFrame frame) {
    debugPrint('STOMP connected');
    _isConnected = true;
    _isAuthenticated = true;
    _setStatus(ConnectionStatus.connected);

    _clearSubscriptions();
    final userId = _userId;
    if (userId != null) {
      _subscribe('/topic/users/$userId', _handleUserMessageFrame);
      _subscribe('/topic/users/$userId/tasks', _handleTaskAlertFrame);
      _subscribe('/topic/users/$userId/marketplace', _handleUserMessageFrame);
      _subscribe('/topic/routes/users/$userId', _handleRouteSnapshotFrame);
      _requestAssignedRoutes(userId);
    }

    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.complete();
    }
  }

  void _subscribe(String destination, void Function(StompFrame frame) handler) {
    try {
      final unsubscribe = _client?.subscribe(
        destination: destination,
        callback: handler,
      );
      if (unsubscribe != null) {
        _unsubscribeCallbacks.add(unsubscribe);
      }
    } catch (e) {
      debugPrint('Failed to subscribe to $destination: $e');
    }
  }

  void _requestAssignedRoutes(int userId) {
    try {
      _client?.send(
        destination: '/app/routes/refresh',
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      debugPrint('Failed to request assigned routes: $e');
    }
  }

  void _handleUserMessageFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) {
      return;
    }

    try {
      final jsonData = jsonDecode(body);
      if (jsonData is! Map<String, dynamic>) {
        return;
      }

      final message = WebSocketMessage<Map<String, dynamic>>.fromJson(jsonData);
      _emitMessage(message);
    } catch (e) {
      debugPrint('Error parsing STOMP user message: $e');
    }
  }

  void _handleTaskAlertFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) {
      return;
    }

    try {
      final jsonData = jsonDecode(body);
      if (jsonData is! Map<String, dynamic>) {
        return;
      }

      final type = jsonData['type']?.toString() ?? 'BIN_ASSIGNED';
      final message = WebSocketMessage<Map<String, dynamic>>(
        type: type,
        userId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: jsonData,
      );
      _emitMessage(message);
    } catch (e) {
      debugPrint('Error parsing task alert: $e');
    }
  }

  void _handleRouteSnapshotFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) {
      return;
    }

    try {
      final jsonData = jsonDecode(body);
      if (jsonData is! Map<String, dynamic>) {
        return;
      }

      final alertType = jsonData['type']?.toString();
      if (alertType == 'ROUTE_ASSIGNED') {
        final message = WebSocketMessage<Map<String, dynamic>>(
          type: 'ROUTE_ASSIGNED',
          userId: _userId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          payload: jsonData,
        );
        _emitMessage(message);
        return;
      }

      final route = jsonData['route'];
      if (route is! Map<String, dynamic>) {
        return;
      }

      final payload = <String, dynamic>{
        'sessionId': jsonData['sessionId']?.toString() ?? '',
        'userId': jsonData['userId'],
        'totalVehiclesUsed': route['totalVehiclesUsed'],
        'routes': route['routes'],
        'updatedAt':
            jsonData['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      };

      final message = WebSocketMessage<Map<String, dynamic>>(
        type: 'ROUTE_UPDATE',
        userId: _userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: payload,
      );

      _emitMessage(message);
    } catch (e) {
      debugPrint('Error parsing route snapshot: $e');
    }
  }

  void _emitMessage(WebSocketMessage<Map<String, dynamic>> message) {
    debugPrint('Received message: ${message.type}');
    if (!_isDisposed && !_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('STOMP websocket error: $error');
    _isConnected = false;
    _isAuthenticated = false;
    _setStatus(ConnectionStatus.error);
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.completeError(Exception(error.toString()));
    }
  }

  void _onWebSocketDone() {
    debugPrint('STOMP websocket closed');
    _isConnected = false;
    _isAuthenticated = false;
    if (_manualDisconnect) {
      _setStatus(ConnectionStatus.disconnected);
    } else {
      _setStatus(ConnectionStatus.reconnecting);
    }
  }

  void _onStompError(StompFrame frame) {
    debugPrint('STOMP broker error: ${frame.body ?? frame.headers}');
    _isConnected = false;
    _isAuthenticated = false;
    _setStatus(ConnectionStatus.error);
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.completeError(
        Exception(frame.body ?? 'STOMP broker error'),
      );
    }
  }

  void _clearSubscriptions() {
    for (final unsubscribe in _unsubscribeCallbacks) {
      try {
        unsubscribe();
      } catch (_) {
        // Ignore unsubscribe errors during reconnect/dispose.
      }
    }
    _unsubscribeCallbacks.clear();
  }

  /// Send a message to the server
  void send(WebSocketMessage<dynamic> message) {
    final client = _client;
    if (client == null) {
      return;
    }

    if (message.type.toUpperCase() != 'ROUTE_REFRESH') {
      debugPrint('STOMP send() is only enabled for ROUTE_REFRESH.');
      return;
    }

    client.send(
      destination: '/app/routes/refresh',
      body: jsonEncode(message.toJson()),
    );
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _isConnected = false;
    _isAuthenticated = false;
    _connectCompleter = null;
    _clearSubscriptions();
    try {
      _client?.deactivate();
    } catch (e) {
      debugPrint('Error disconnecting STOMP client: $e');
    } finally {
      _client = null;
      _setStatus(ConnectionStatus.disconnected);
    }
  }

  /// Dispose resources
  void dispose() {
    _isDisposed = true;
    _clearSubscriptions();
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
  reconnectionFailed,
}
