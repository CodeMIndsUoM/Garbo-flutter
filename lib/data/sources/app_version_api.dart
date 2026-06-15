import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/app_version_info.dart';

class AppVersionApi {
  final http.Client client;

  AppVersionApi({required this.client});

  Future<AppVersionInfo?> fetchLatestVersion() async {
    final platform = _platformKey;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.appVersion}?platform=$platform',
    );

    final response = await client.get(
      url,
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] == false) return null;

    final data = body['data'];
    if (data is! Map<String, dynamic>) return null;

    return AppVersionInfo.fromJson(data);
  }
}

String get _platformKey {
  if (kIsWeb) return 'android';
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'ios';
    default:
      return 'android';
  }
}
