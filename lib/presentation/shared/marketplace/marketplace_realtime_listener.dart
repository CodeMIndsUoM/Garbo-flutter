import 'dart:async';

import 'package:garbo_swms/data/models/websocket_message_model.dart';
import 'package:garbo_swms/presentation/providers/websocket_provider.dart';

/// Listens for marketplace STOMP events and triggers a refresh callback.
class MarketplaceRealtimeListener {
  static const _marketplaceTypes = {'REQUEST_UPDATED', 'OFFER_UPDATED'};

  static StreamSubscription<WebSocketMessage<Map<String, dynamic>>>? attach(
    WebSocketProvider provider,
    void Function() onUpdate,
  ) {
    return provider.messageStream.listen((message) {
      if (_marketplaceTypes.contains(message.type.toUpperCase())) {
        onUpdate();
      }
    });
  }
}
