class ApiConstants {
  // Host options:
  //   • USB-connected Android (adb reverse tcp:8081 tcp:8081) : http://127.0.0.1:8081/api
  //   • Android Emulator                                      : http://10.0.2.2:8081/api
  //   • iOS Simulator                                         : http://127.0.0.1:8081/api
  //   • Physical device over Wi-Fi                            : http://<mac-lan-ip>:8081/api
  //   • Flutter Web (local)                                   : http://127.0.0.1:8081/api
  static const String baseUrl = 'http://127.0.0.1:8081/api';

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

  // App version check (public, no auth)
  static const String appVersion = '/app/version';
}
