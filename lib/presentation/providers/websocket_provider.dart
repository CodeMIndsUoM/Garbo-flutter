import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/data/sources/websocket_service.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';

/// WebSocketProvider manages WebSocket connection state and provides access to message streams
class WebSocketProvider extends ChangeNotifier {
  final AuthProvider authProvider;

  late WebSocketService _webSocketService;
  StreamSubscription<ConnectionStatus>? _statusSubscription;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  String? _errorMessage;

  ConnectionStatus get connectionStatus => _connectionStatus;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  bool get isAuthenticated => _webSocketService.isAuthenticated;
  Stream<WebSocketMessage<Map<String, dynamic>>> get messageStream =>
      _webSocketService.messageStream;

  WebSocketProvider(this.authProvider) {
    _webSocketService = authProvider.webSocketService;
    _connectionStatus = _webSocketService.currentStatus;
    _listenToStatusChanges();
  }

  /// Listen to WebSocket status changes
  void _listenToStatusChanges() {
    _statusSubscription?.cancel();
    _statusSubscription = _webSocketService.statusStream.listen((status) {
      _applyStatus(status);
    });
  }

  void _applyStatus(ConnectionStatus status) {
    if (_connectionStatus == status) {
      return;
    }
    _connectionStatus = status;
    _updateErrorMessage(status);
    notifyListeners();
  }

  /// Update error message based on connection status
  void _updateErrorMessage(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        _errorMessage = 'Disconnected';
        break;
      case ConnectionStatus.connecting:
        _errorMessage = null;
        break;
      case ConnectionStatus.connected:
        _errorMessage = null;
        break;
      case ConnectionStatus.reconnecting:
        _errorMessage = 'Reconnecting...';
        break;
      case ConnectionStatus.error:
        _errorMessage = 'Connection error';
        break;
      case ConnectionStatus.reconnectionFailed:
        _errorMessage = 'Reconnection failed. Please login again.';
        break;
    }
  }

  /// Get visual indicator for connection status
  String get statusIndicator {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return '🟢 Connected';
      case ConnectionStatus.connecting:
        return '🟡 Connecting';
      case ConnectionStatus.reconnecting:
        return '🟡 Reconnecting';
      case ConnectionStatus.error:
      case ConnectionStatus.reconnectionFailed:
        return '🔴 Disconnected';
      default:
        return '⚫ Unknown';
    }
  }

  void sendMessage({
    required String type,
    required int userId,
    Map<String, dynamic>? payload,
  }) {
    _webSocketService.send(
      WebSocketMessage<Map<String, dynamic>>(
        type: type,
        userId: userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        payload: payload,
      ),
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
