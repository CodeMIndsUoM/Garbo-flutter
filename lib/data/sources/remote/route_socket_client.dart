import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:garbo_swms/data/models/route_snapshot_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class RouteSocketClient {
  final String backendBaseUrl;
  final int userId;
  final String? authToken;

  StompClient? stompClient;
  int latestVersion = -1;
  String? activeSessionId;
  bool isStarted = false;

  RouteSocketClient({
    required this.backendBaseUrl,
    required this.userId,
    this.authToken,
  });

  Future<void> start({
    required void Function(RouteSnapshot snapshot) onReady,
    required void Function(RouteSnapshot snapshot) onProcessing,
    required void Function(RouteSnapshot snapshot) onError,
    VoidCallback? onConnected,
    void Function(Object error)? onSocketError,
    VoidCallback? onDisconnected,
  }) async {
    if (isStarted) return;

    final wsUrl = buildWsUrl(backendBaseUrl);

    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          onConnected?.call();
          stompClient?.subscribe(
            destination: '/topic/routes/users/$userId',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;

              try {
                final jsonMap = jsonDecode(body) as Map<String, dynamic>;
                final snapshot = RouteSnapshot.fromJson(jsonMap);

                if (snapshot.sessionId != activeSessionId) {
                  activeSessionId = snapshot.sessionId;
                  latestVersion = -1;
                }

                if (snapshot.version <= latestVersion) {
                  return;
                }
                latestVersion = snapshot.version;

                switch (snapshot.status.toUpperCase()) {
                  case 'READY':
                    onReady(snapshot);
                    break;
                  case 'PROCESSING':
                    onProcessing(snapshot);
                    break;
                  case 'ERROR':
                    onError(snapshot);
                    break;
                  default:
                    debugPrint(
                      'RouteSocketClient: unhandled status ${snapshot.status}',
                    );
                }
              } catch (error) {
                onSocketError?.call(error);
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          onSocketError?.call(error as Object);
          debugPrint('RouteSocketClient WebSocket error: $error');
        },
        onStompError: (dynamic frame) {
          debugPrint('RouteSocketClient STOMP error: ${frame.body}');
        },
        onDisconnect: (frame) {
          onDisconnected?.call();
          debugPrint('RouteSocketClient disconnected');
        },
        stompConnectHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : const {},
        webSocketConnectHeaders: authToken != null
            ? {'Authorization': 'Bearer $authToken'}
            : const {},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    stompClient?.activate();
    isStarted = true;
  }

  void stop() {
    if (!isStarted) return;
    stompClient?.deactivate();
    isStarted = false;
    latestVersion = -1;
    activeSessionId = null;
  }

  String buildWsUrl(String baseUrl) {
    final normalized = baseUrl.trim();
    if (normalized.startsWith('ws://') || normalized.startsWith('wss://')) {
      final parsed = Uri.parse(normalized);
      final wsUri = parsed.replace(
        path: appendPath(parsed.path, 'ws'),
      );
      return wsUri.toString();
    }

    final parsed = Uri.parse(normalized);
    final wsScheme = parsed.scheme == 'https' ? 'wss' : 'ws';
    final wsUri = parsed.replace(
      scheme: wsScheme,
      path: appendPath(parsed.path, 'ws'),
    );
    return wsUri.toString();
  }

  String appendPath(String currentPath, String segment) {
    final cleaned = currentPath.endsWith('/')
        ? currentPath.substring(0, currentPath.length - 1)
        : currentPath;

    if (cleaned.isEmpty || cleaned == '/') {
      return '/$segment';
    }

    return '$cleaned/$segment';
  }
}
