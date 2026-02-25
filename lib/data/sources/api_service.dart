import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Fetches bins assigned to a specific field mentor.
  Future<List<BinModel>> getAssignedBins(String empId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId/bins');
    try {
      final response = await client.get(url);

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
  Future<bool> reportBinStatus(String empId, String binId, Map<String, dynamic> reportData) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId/bins/$binId/report');
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
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
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/$empId');
    try {
      final response = await client.get(url);

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
