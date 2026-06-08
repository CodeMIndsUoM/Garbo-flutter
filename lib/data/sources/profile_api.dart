import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:garbo_swms/core/constants/api_constants.dart';

typedef AuthHeadersProvider = Future<Map<String, String>> Function();
typedef TokenProvider = Future<String> Function();

class ProfileApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;
  final TokenProvider tokenProvider;

  ProfileApi({
    required this.client,
    required this.authHeadersProvider,
    required this.tokenProvider,
  });

  Future<String> getFieldMentorName(String empId) async {
    if (empId.isEmpty) {
      return 'Field Staff';
    }
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId',
    );
    try {
      final headers = await authHeadersProvider();
      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data']['empName'] ?? 'Field Staff';
        }
      }
      return 'Field Staff';
    } catch (_) {
      return 'Field Staff';
    }
  }

  Future<String> getStoredEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('empId') ?? '';
  }

  Future<String> getStoredEmpName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('empName') ?? 'Collector';
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (userId.isEmpty) return null;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId',
    );
    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) return body['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    if (userId.isEmpty) return false;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId',
    );
    final headers = await authHeadersProvider();
    final response = await client.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        if (data['empName'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('empName', data['empName']);
        }
        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>?> getThirdPartyCollectorProfile(
    String collectorId,
  ) async {
    if (collectorId.isEmpty) return null;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/profile',
    );
    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) return body['data'] as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> updateThirdPartyCollectorProfile(
    String collectorId,
    Map<String, dynamic> data,
  ) async {
    if (collectorId.isEmpty) return false;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/profile',
    );
    final headers = await authHeadersProvider();
    final response = await client.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        if (data['empName'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('empName', data['empName']);
        }
        return true;
      }
    }
    return false;
  }

  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    if (userId.isEmpty) return null;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/avatar',
    );
    final token = await tokenProvider();

    final request = http.MultipartRequest('POST', url);
    if (token.isNotEmpty) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('photo', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        return data['avatarUrl'] as String?;
      }
    }
    return null;
  }

  Future<bool> removeProfilePicture(String userId) async {
    if (userId.isEmpty) return false;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.users}/$userId/avatar',
    );
    final headers = await authHeadersProvider();
    final response = await client.delete(url, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['success'] == true;
    }
    return false;
  }

  Future<bool> removeThirdPartyProfilePicture(String collectorId) async {
    if (collectorId.isEmpty) return false;
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/avatar',
    );
    final headers = await authHeadersProvider();
    final response = await client.delete(url, headers: headers);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['success'] == true;
    }
    return false;
  }
}
