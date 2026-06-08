import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/app_notification_model.dart';

typedef AuthHeadersProvider = Future<Map<String, String>> Function();

class NotificationApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;

  NotificationApi({
    required this.client,
    required this.authHeadersProvider,
  });

  Future<bool> registerDeviceToken({
    required int empId,
    required String token,
  }) async {
    if (empId <= 0 || token.isEmpty) return false;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.deviceTokens(empId)}',
    );
    final headers = await authHeadersProvider();
    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode({
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['success'] == true || body['success'] == null;
    }
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> unregisterDeviceToken({
    required int empId,
    required String token,
  }) async {
    if (empId <= 0 || token.isEmpty) return false;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.deviceTokens(empId)}',
    );
    final headers = await authHeadersProvider();
    final response = await client.delete(
      url,
      headers: headers,
      body: jsonEncode({'token': token}),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<List<AppNotificationModel>> fetchNotifications(int empId) async {
    if (empId <= 0) return const [];

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.userNotifications(empId)}',
    );
    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);

    if (response.statusCode != 200) return const [];

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return const [];

    final data = body['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(AppNotificationModel.fromJson)
        .toList();
  }

  Future<bool> markAsRead(String notificationId) async {
    if (notificationId.isEmpty) return false;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.notificationRead(notificationId)}',
    );
    final headers = await authHeadersProvider();
    final response = await client.patch(url, headers: headers);

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> markAllAsRead(int empId) async {
    if (empId <= 0) return false;

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.markAllNotificationsRead(empId)}',
    );
    final headers = await authHeadersProvider();
    final response = await client.patch(url, headers: headers);

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
