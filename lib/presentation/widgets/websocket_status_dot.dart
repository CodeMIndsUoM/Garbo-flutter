import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garbo_swms/data/sources/websocket_service.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

class WebSocketStatusDot extends StatelessWidget {
  final double size;

  const WebSocketStatusDot({super.key, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketProvider>(
      builder: (context, wsProvider, _) {
        final status = wsProvider.connectionStatus;
        final effectiveStatus = wsProvider.isAuthenticated
            ? ConnectionStatus.connected
            : status;
        final color = _colorForStatus(effectiveStatus);
        final label = _labelForStatus(effectiveStatus);

        return Tooltip(
          message: 'WebSocket: $label',
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _colorForStatus(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return const Color(0xFF22C55E); // green
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return const Color(0xFFF59E0B); // amber
      case ConnectionStatus.error:
      case ConnectionStatus.reconnectionFailed:
      case ConnectionStatus.disconnected:
        return const Color(0xFFEF4444); // red
    }
  }

  String _labelForStatus(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.reconnectionFailed:
        return 'Reconnect Failed';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }
}
