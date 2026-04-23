import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/models/collector_dashboard_model.dart';
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

  Future<String> getStoredEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('empId') ?? '';
  }

  Future<List<CollectionRequestModel>> getCitizenCollectionRequests(
    String citizenId, {
    String? status,
  }) async {
    if (citizenId.isEmpty) {
      throw Exception('Citizen ID is empty. Please log in again.');
    }

    final query = status == null ? '' : '?status=$status';
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.citizens}/$citizenId${ApiConstants.collectionRequests}$query',
    );

    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load requests');
    }

    final data = body['data'] as List<dynamic>? ?? const [];
    return data
        .map(
          (item) => CollectionRequestModel.fromSummaryJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<CollectionRequestModel> getCollectionRequestDetail(
    int requestId,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.collectionRequests}/$requestId',
    );

    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load request detail');
    }

    return CollectionRequestModel.fromDetailJson(
      body['data'] as Map<String, dynamic>,
    );
  }

  Future<CollectionRequestModel> createCollectionRequest({
    required String citizenId,
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.citizens}/$citizenId${ApiConstants.collectionRequests}',
    );

    final headers = await _authHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to create request');
    }

    return CollectionRequestModel.fromSummaryJson(
      body['data'] as Map<String, dynamic>,
    );
  }

  Future<String> uploadCitizenRequestPhoto({
    required String citizenId,
    required String photoPath,
  }) async {
    if (citizenId.isEmpty) {
      throw Exception('Citizen ID is empty. Please log in again.');
    }

    final file = File(photoPath);
    if (!await file.exists()) {
      throw Exception('Selected image file was not found.');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.citizens}/$citizenId/request-photo',
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final request = http.MultipartRequest('POST', url);
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to upload request photo');
    }

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final photoUrl = data['photoUrl']?.toString();
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      throw Exception('Backend did not return a photo URL.');
    }
    return photoUrl;
  }

  Future<CollectionOfferModel> acceptOffer(int offerId) async {
    return _offerAction(offerId, 'accept');
  }

  Future<CollectionOfferModel> rejectOffer(int offerId) async {
    return _offerAction(offerId, 'reject');
  }

  Future<CollectionOfferModel> _offerAction(int offerId, String action) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/$action',
    );
    final headers = await _authHeaders();
    final response = await client.post(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to $action offer');
    }

    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<CollectionRequestModel>> getCollectorFeed(
    String collectorId, {
    double? lat,
    double? lng,
  }) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final params = <String, String>{};
    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/feed',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load collector feed');
    }

    final data = body['data'] as List<dynamic>? ?? const [];
    return data
        .map(
          (item) => CollectionRequestModel.fromSummaryJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<CollectionOfferModel> sendCollectorOffer({
    required int requestId,
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.collectionRequests}/$requestId/offers',
    );

    final headers = await _authHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(payload),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to send offer');
    }

    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<CollectionOfferModel>> getCollectorOffers(
    String collectorId, {
    String? status,
  }) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final params = <String, String>{};
    if (status != null && status.trim().isNotEmpty) {
      params['status'] = status.trim();
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/my-offers',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load offers');
    }

    final data = body['data'] as List<dynamic>? ?? const [];
    return data
        .map(
          (item) => CollectionOfferModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<CollectionOfferModel>> getCollectorActiveJobs(
    String collectorId,
  ) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/active-jobs',
    );

    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load active jobs');
    }

    final data = body['data'] as List<dynamic>? ?? const [];
    return data
        .map(
          (item) => CollectionOfferModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<CollectionOfferModel> withdrawOffer(int offerId) async {
    return _offerAction(offerId, 'withdraw');
  }

  Future<void> hideOffer(int offerId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/hide',
    );

    final headers = await _authHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(<String, dynamic>{}),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to remove offer from list');
    }
  }

  Future<int> hideCollectorOffers({
    required String collectorId,
    List<String>? statuses,
  }) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final params = <String, String>{};
    if (statuses != null && statuses.isNotEmpty) {
      params['statuses'] = statuses.join(',');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/my-offers/hide',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final headers = await _authHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(<String, dynamic>{}),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to clear offers');
    }

    final data = body['data'] as Map<String, dynamic>? ?? const {};
    return (data['hiddenCount'] as num?)?.toInt() ?? 0;
  }

  Future<CollectionOfferModel> startOffer(int offerId) async {
    return _offerAction(offerId, 'start');
  }

  Future<CollectionOfferModel> cancelOffer({
    required int offerId,
    required String reason,
    String? note,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/cancel',
    );

    final headers = await _authHeaders();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode({'reason': reason, 'note': note}),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to cancel offer');
    }

    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<CollectionOfferModel> completeOffer({
    required int offerId,
    required String photoPath,
    required double latitude,
    required double longitude,
    double? weightKg,
    String? notes,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/complete',
    );

    final file = File(photoPath);
    if (!await file.exists()) {
      throw Exception('Completion photo file not found. Please capture again.');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final request = http.MultipartRequest('POST', url)
      ..fields['latitude'] = latitude.toString()
      ..fields['longitude'] = longitude.toString();

    if (weightKg != null) {
      request.fields['weightKg'] = weightKg.toString();
    }
    if (notes != null && notes.trim().isNotEmpty) {
      request.fields['notes'] = notes.trim();
    }
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to complete offer');
    }

    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<CollectorDashboardModel> getCollectorDashboard(
    String collectorId,
  ) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/dashboard',
    );

    final headers = await _authHeaders();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load dashboard');
    }

    return CollectorDashboardModel.fromJson(
      body['data'] as Map<String, dynamic>,
    );
  }
}
