import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:garbo_swms/core/constants/api_constants.dart';

typedef AuthHeadersProvider = Future<Map<String, String>> Function();
typedef TokenProvider = Future<String> Function();

class AuthApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;
  final TokenProvider tokenProvider;

  AuthApi({
    required this.client,
    required this.authHeadersProvider,
    required this.tokenProvider,
  });

  Future<List<String>> fetchCouncils() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/councils');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    final body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load councils');
    }
    final data = body['data'] as List<dynamic>? ?? const [];
    return data.map((item) => item.toString()).toList();
  }

  Future<Map<String, dynamic>> registerCitizen({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String council,
    String? address,
    String? area,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'council': council,
        if (address != null && address.isNotEmpty) 'address': address,
        if (area != null && area.isNotEmpty) 'area': area,
      }),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Registration failed');
    }
    return body;
  }
}

class ComplaintApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;
  final TokenProvider tokenProvider;

  ComplaintApi({
    required this.client,
    required this.authHeadersProvider,
    required this.tokenProvider,
  });

  Future<List<Map<String, dynamic>>> getMyComplaints() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/complaints/my');
    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load complaints');
    }
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> createComplaint(Map<String, dynamic> payload) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/complaints');
    final headers = await authHeadersProvider();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit report');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<String?> uploadComplaintImage(File imageFile) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/complaints/upload-image');
    final token = await tokenProvider();
    final request = http.MultipartRequest('POST', url);
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      await http.MultipartFile.fromPath('photo', imageFile.path),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['photoUrl'] as String?;
    }
    return null;
  }
}

class EventApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;

  EventApi({
    required this.client,
    required this.authHeadersProvider,
  });

  Future<List<Map<String, dynamic>>> getEvents() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/events');
    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load events');
    }
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> enrollInEvent(int eventId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/events/$eventId/enroll');
    final headers = await authHeadersProvider();
    final response = await client.post(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to enroll in event');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyEvents() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/events/my');
    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load my events');
    }
    final decoded = json.decode(response.body);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> suggestEvent(Map<String, dynamic> payload) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/events/suggestions');
    final headers = await authHeadersProvider();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to suggest event');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }
}
