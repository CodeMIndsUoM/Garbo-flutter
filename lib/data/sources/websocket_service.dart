import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:garbo_swms/data/models/websocket_message_model.dart';

/// Low-level WebSocket client for GARBO real-time updates.
/// Handles connection, handshaking, and message streaming.
class WebSocketService {
  WebSocketChannel? _channel;
  late StreamController<WebSocketMessage<Map<String, dynamic>>>
      _messageController;
  late StreamController<ConnectionStatus> _statusController;
  
  String? _serverUrl;
  int? _userId;
  bool _isConnected = false;
  bool _isAuthenticated = false;
  bool _manualDisconnect = false;
  bool _isDisposed = false;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  Timer? _reconnectTimer;
  StreamSubscription? _channelSubscription;
  int _reconnectAttempt = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration initialReconnectDelay = Duration(seconds: 1);

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
    _messageController = StreamController<WebSocketMessage<Map<String, dynamic>>>.broadcast();
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
      _manualDisconnect = false;
      _serverUrl = serverUrl;
      _userId = userId;
      _isConnected = false;
      _isAuthenticated = false;
      
      _setStatus(ConnectionStatus.connecting);
      
      final wsUrl = _toWebSocketUrl(serverUrl);
      debugPrint('Connecting to WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      
      // Listen to incoming messages
      _channelSubscription?.cancel();
      _channelSubscription = _channel!.stream.listen(
        _onMessageReceived,
        onError: _onError,
        onDone: _onDone,
      );
      
      _reconnectAttempt = 0;

      // Send AUTH handshake
      await sendAuthHandshake(userId);
      
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _isConnected = false;
      _setStatus(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  String _toWebSocketUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    String basePath = uri.path;
    
    // Strip trailing slash
    if (basePath.endsWith('/')) {
      basePath = basePath.substring(0, basePath.length - 1);
    }
    
    // Strip '/api' if it exists at the end of the path
    if (basePath.endsWith('/api')) {
      basePath = basePath.substring(0, basePath.length - 4);
    }
    
    final wsPath = '$basePath/ws'.replaceAll('//', '/');
    return uri.replace(scheme: wsScheme, path: wsPath).toString();
  }

  /// Send AUTH handshake to server
  Future<void> sendAuthHandshake(int userId) async {
    try {
      final authPayload = AuthPayload(userId: userId);
      final message = WebSocketMessage<AuthPayload>(
        type: 'AUTH',
        userId: userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: authPayload,
      );
      
      final jsonStr = jsonEncode({
        'type': message.type,
        'userId': message.userId,
        'timestamp': message.timestamp,
        'payload': message.payload?.toJson(),
      });
      
      _channel?.sink.add(jsonStr);
      debugPrint('AUTH handshake sent');
      
      // Wait for CONFIRMED response with timeout.
      await _waitForConfirmedMessage();
      
    } catch (e) {
      debugPrint('Auth handshake error: $e');
      _isAuthenticated = false;
      disconnect();
      rethrow;
    }
  }

  /// Wait for CONFIRMED message from server
  Future<void> _waitForConfirmedMessage() {
    final completer = Completer<void>();
    StreamSubscription<WebSocketMessage<Map<String, dynamic>>>? subscription;
    Timer? timeoutTimer;

    void finishError(Object error) {
      timeoutTimer?.cancel();
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    timeoutTimer = Timer(const Duration(seconds: 5), () {
      finishError(Exception('AUTH confirmation timeout'));
    });
    
    subscription = messageStream.listen((message) {
      if (message.type == 'CONFIRMED') {
        _isAuthenticated = true;
        _setStatus(ConnectionStatus.connected);
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription?.cancel();
      }
    }, onError: finishError);

    completer.future.whenComplete(() {
      timeoutTimer?.cancel();
      subscription?.cancel();
    });

    return completer.future;
  }

  /// Handle incoming messages
  void _onMessageReceived(dynamic data) {
    try {
      final jsonData = jsonDecode(data as String) as Map<String, dynamic>;
      final message = WebSocketMessage<Map<String, dynamic>>.fromJson(jsonData);

      debugPrint('Received message: ${message.type}');
      if (!_isDisposed && !_messageController.isClosed) {
        _messageController.add(message);
      }
      
    } catch (e) {
      debugPrint('Error parsing message: $e');
      if (!_isDisposed && !_messageController.isClosed) {
        _messageController.addError(e);
      }
    }
  }

  /// Handle connection error
  void _onError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    _isAuthenticated = false;
    _setStatus(ConnectionStatus.error);
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  /// Handle connection closed
  void _onDone() {
    debugPrint('WebSocket connection closed');
    _isConnected = false;
    _isAuthenticated = false;
    _setStatus(ConnectionStatus.disconnected);
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  /// Schedule automatic reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_manualDisconnect || _isDisposed) {
      return;
    }

    if (_reconnectAttempt >= maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      _setStatus(ConnectionStatus.reconnectionFailed);
      return;
    }
    
    _reconnectAttempt++;
    final delaySeconds = (initialReconnectDelay.inSeconds) *
        (1 << (_reconnectAttempt - 1)); // Exponential backoff
    final capped = delaySeconds > 8 ? 8 : delaySeconds;

    debugPrint('Reconnecting in ${capped}s (attempt $_reconnectAttempt)');
    _setStatus(ConnectionStatus.reconnecting);
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: capped), () async {
      if (_serverUrl != null && _userId != null) {
        await connect(_serverUrl!, _userId!);
      }
    });
  }

  /// Send a message to the server
  void send(WebSocketMessage<dynamic> message) {
    if (!_isAuthenticated) {
      debugPrint('Cannot send message: not authenticated');
      return;
    }
    
    try {
      final jsonStr = jsonEncode({
        'type': message.type,
        'userId': message.userId,
        'timestamp': message.timestamp,
        'payload': message.payload,
      });
      _channel?.sink.add(jsonStr);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _isConnected = false;
    _isAuthenticated = false;
    
    try {
      await _channelSubscription?.cancel();
      if (_channel != null) {
        await _channel!.sink.close(status.goingAway);
      }
      _setStatus(ConnectionStatus.disconnected);
      debugPrint('WebSocket disconnected');
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    } finally {
      _channel = null;
    }
  }

  /// Dispose resources
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
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
