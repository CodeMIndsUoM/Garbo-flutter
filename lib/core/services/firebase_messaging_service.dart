import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:garbo_swms/core/services/local_notification_service.dart';
import 'package:garbo_swms/data/models/app_notification_model.dart';
import 'package:garbo_swms/firebase_options.dart';

/// Background FCM handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background: ${message.messageId}');
}

typedef RemoteNotificationHandler = void Function(AppNotificationModel model);

class FirebaseMessagingService {
  FirebaseMessagingService({
    LocalNotificationService? localNotifications,
  }) : _localNotifications =
            localNotifications ?? LocalNotificationService();

  final LocalNotificationService _localNotifications;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final StreamController<AppNotificationModel> _incomingController =
      StreamController<AppNotificationModel>.broadcast();

  Stream<AppNotificationModel> get onNotification =>
      _incomingController.stream;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;

  bool _initialized = false;

  Future<void> initialize({
    RemoteNotificationHandler? onForegroundMessage,
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_initialized) return;

    await _localNotifications.initialize(
      onNotificationTap: onNotificationTap,
    );

    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      final model = _toModel(message);
      _incomingController.add(model);
      onForegroundMessage?.call(model);

      final title = model.title;
      final body = model.body;
      if (title.isNotEmpty || body.isNotEmpty) {
        _localNotifications.show(
          id: model.id.hashCode,
          title: title,
          body: body,
          payload: model.data == null ? null : jsonEncode(model.data),
        );
      }
    });

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('FCM getToken error: $e');
      return null;
    }
  }

  void listenToTokenRefresh(void Function(String token) onRefresh) {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(onRefresh);
  }

  AppNotificationModel messageToModel(RemoteMessage message) =>
      _toModel(message);

  AppNotificationModel _toModel(RemoteMessage message) {
    final notification = message.notification;
    final data = Map<String, dynamic>.from(message.data);

    return AppNotificationModel.fromRemoteMessage(
      messageId: message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ??
          data['title']?.toString() ??
          'Garbo',
      body: notification?.body ?? data['body']?.toString() ?? '',
      data: data,
    );
  }

  void dispose() {
    _foregroundSub?.cancel();
    _tokenRefreshSub?.cancel();
    _incomingController.close();
  }
}
