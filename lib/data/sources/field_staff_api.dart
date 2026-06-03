import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

typedef AuthHeadersProvider = Future<Map<String, String>> Function();
typedef TokenProvider = Future<String> Function();

class FieldStaffApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;
  final TokenProvider tokenProvider;

  FieldStaffApi({
    required this.client,
    required this.authHeadersProvider,
    required this.tokenProvider,
  });

  Future<List<BinModel>> getAssignedBins() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.fieldMentors}/me/bins',
    );
    try {
      final headers = await authHeadersProvider();
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

  Future<bool> reportBinStatus({
    required String binId,
    required Map<String, dynamic> reportData,
    String? photoPath,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.bins}/$binId/report',
    );
    try {
      final token = await tokenProvider();

      final request = http.MultipartRequest('POST', url);

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      reportData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (photoPath != null && photoPath.trim().isNotEmpty) {
        final file = File(photoPath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('photo', photoPath),
          );
        } else {
          throw Exception('Selected image file was not found.');
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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

  Future<bool> undoBinReport(String binId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.bins}/$binId/undo',
    );

    try {
      final headers = await authHeadersProvider();
      final response = await client.post(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return body['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error undoing bin report: $e');
    }
  }
}
