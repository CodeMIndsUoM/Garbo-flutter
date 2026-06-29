import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Override at build time: --dart-define=API_BASE=https://garboadmin.duckdns.org/api
  // Local dev defaults:
  //   USB Android (adb reverse) : http://127.0.0.1:8081/api
  //   Android Emulator        : http://10.0.2.2:8081/api
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE', defaultValue: '');
    if (env.isNotEmpty) return env;
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:8081/api';
    }
    try {
      if (Platform.isAndroid) return 'http://127.0.0.1:8081/api';
      return 'http://127.0.0.1:8081/api';
    } catch (e) {
      return 'http://127.0.0.1:8081/api';
    }
  }

  // Field Mentor Endpoints
  static const String fieldMentors = '/fieldmentors';
  static const String bins = '/bins';

  // Collection request endpoints
  static const String citizens = '/citizens';
  static const String collectionRequests = '/collection-requests';
  static const String offers = '/offers';
  static const String thirdPartyCollectors = '/thirdpartycollectors';

  // User endpoints
  static const String users = '/users';

  // Push notification endpoints (relative to baseUrl)
  static String deviceTokens(int empId) => '/users/$empId/device-tokens';
  static String userNotifications(int empId) => '/users/$empId/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static String markAllNotificationsRead(int empId) =>
      '/users/$empId/notifications/read-all';

  // Third-party collector registration (public, no auth)
  static const String thirdPartyRegister = '/auth/thirdparty-register';
}
