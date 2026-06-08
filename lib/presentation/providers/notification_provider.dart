import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garbo_swms/core/services/firebase_bootstrap.dart';
import 'package:garbo_swms/core/services/firebase_messaging_service.dart';
import 'package:garbo_swms/data/models/app_notification_model.dart';
import 'package:garbo_swms/data/sources/notification_api.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages FCM token registration, notification history, and unread counts.
class NotificationProvider extends ChangeNotifier {
  static const _cachedTokenKey = 'fcm_device_token';

  final AuthProvider authProvider;
  final NotificationApi notificationApi;
  final FirebaseMessagingService messagingService;

  NotificationProvider({
    required this.authProvider,
    required this.notificationApi,
    FirebaseMessagingService? messagingService,
  }) : messagingService = messagingService ?? FirebaseMessagingService();

  List<AppNotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _fcmToken;
  StreamSubscription<AppNotificationModel>? _incomingSub;
  bool _initialized = false;
  bool _wasAuthenticated = false;

  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.read).length;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (isFirebaseAvailable) {
      await messagingService.initialize(
        onForegroundMessage: _prependNotification,
      );

      _incomingSub =
          messagingService.onNotification.listen(_prependNotification);

      messagingService.listenToTokenRefresh((token) {
        _fcmToken = token;
        _registerTokenIfAuthenticated(token);
      });
    }

    if (authProvider.isAuthenticated) {
      _wasAuthenticated = true;
      await onUserAuthenticated();
    }
  }

  Future<void> handleAuthChange(bool isAuthenticated) async {
    if (!_initialized) return;

    if (isAuthenticated && !_wasAuthenticated) {
      _wasAuthenticated = true;
      await onUserAuthenticated();
    } else if (!isAuthenticated && _wasAuthenticated) {
      _wasAuthenticated = false;
      await onUserLoggedOut();
    }
  }

  Future<void> onUserAuthenticated() async {
    if (isFirebaseAvailable) {
      await messagingService.requestPermission();
      _fcmToken = await messagingService.getToken();
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cachedTokenKey, _fcmToken!);
        await _registerTokenIfAuthenticated(_fcmToken!);
      }
    }
    await refresh();
  }

  Future<void> onUserLoggedOut() async {
    final empId = authProvider.currentUser?.empId;
    final token = _fcmToken;
    if (empId != null && token != null && token.isNotEmpty) {
      try {
        await notificationApi.unregisterDeviceToken(
          empId: empId,
          token: token,
        );
      } catch (e) {
        debugPrint('FCM unregister error: $e');
      }
    }
    _notifications = [];
    notifyListeners();
  }

  Future<void> refresh() async {
    final empId = authProvider.currentUser?.empId;
    if (empId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await notificationApi.fetchNotifications(empId);
    } catch (e) {
      _error = 'Could not load notifications';
      debugPrint('Notification refresh error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index < 0) return;

    _notifications[index] = _notifications[index].copyWith(read: true);
    notifyListeners();

    try {
      await notificationApi.markAsRead(notificationId);
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final empId = authProvider.currentUser?.empId;
    if (empId == null) return;

    _notifications = [
      for (final n in _notifications) n.copyWith(read: true),
    ];
    notifyListeners();

    try {
      await notificationApi.markAllAsRead(empId);
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
    }
  }

  void _prependNotification(AppNotificationModel model) {
    final existingIndex =
        _notifications.indexWhere((n) => n.id == model.id);
    if (existingIndex >= 0) {
      _notifications.removeAt(existingIndex);
    }
    _notifications.insert(0, model);
    notifyListeners();
  }

  Future<void> _registerTokenIfAuthenticated(String token) async {
    final empId = authProvider.currentUser?.empId;
    if (empId == null || !authProvider.isAuthenticated) return;

    try {
      await notificationApi.registerDeviceToken(empId: empId, token: token);
    } catch (e) {
      debugPrint('FCM register error: $e');
    }
  }

  @override
  void dispose() {
    _incomingSub?.cancel();
    messagingService.dispose();
    super.dispose();
  }
}
