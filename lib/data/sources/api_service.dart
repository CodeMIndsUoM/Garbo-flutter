import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Gets auth headers with JWT token from SharedPreferences.
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches bins assigned to a specific field mentor.
  Future<List<BinModel>> getAssignedBins(String empId) async {
    if (empId.isEmpty) {
      throw Exception('Employee ID is empty. Please log in again.');
    }
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId/bins',
    );
    try {
      final headers = await _authHeaders();
      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((json) => BinModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load bins: ${body['message']}');
        }
      } else {
        throw Exception('Failed to load bins: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bins: $e');
    }
  }

  /// Reports the status of a bin.
  Future<bool> reportBinStatus(
    String empId,
    String binId,
    Map<String, dynamic> reportData,
  ) async {
    if (empId.isEmpty) {
      throw Exception('Employee ID is empty. Please log in again.');
    }
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId/bins/$binId/report',
    );
    try {
      final headers = await _authHeaders();
      final response = await client.post(
        url,
        headers: headers,
        body: json.encode(reportData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return body['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error reporting bin status: $e');
    }
  }

  /// Undoes a bin report, resetting it to notChecked.
  Future<bool> undoBinReport(String empId, String binId) async {
    return reportBinStatus(empId, binId, {
      "status": "notChecked",
      "fillLevel": 0,
      "notes": "Undo report",
      "latitude": 6.9,
      "longitude": 79.8,
    });
  }

  /// Fetches the name of a specific field mentor.
  Future<String> getFieldMentorName(String empId) async {
    if (empId.isEmpty) {
      return 'Field Staff';
    }
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId',
    );
    try {
      final headers = await _authHeaders();
      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data']['empName'] ?? 'Field Staff';
        }
      }
      return 'Field Staff';
    } catch (e) {
      // Fail silently for UI polish
      return 'Field Staff';
    }
  }
}
