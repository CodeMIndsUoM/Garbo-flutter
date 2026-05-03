import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/models/collector_dashboard_model.dart';

typedef AuthHeadersProvider = Future<Map<String, String>> Function();
typedef TokenProvider = Future<String> Function();

class ThirdPartyCollectorApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;
  final TokenProvider tokenProvider;

  ThirdPartyCollectorApi({
    required this.client,
    required this.authHeadersProvider,
    required this.tokenProvider,
  });

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

    final headers = await authHeadersProvider();
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

    final headers = await authHeadersProvider();
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

    final headers = await authHeadersProvider();
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

  Future<List<CollectionOfferModel>> getCollectorActiveJobs(String collectorId) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/active-jobs',
    );

    final headers = await authHeadersProvider();
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

  Future<CollectionOfferModel> withdrawOffer(int offerId) {
    return _offerAction(offerId, 'withdraw');
  }

  Future<void> hideOffer(int offerId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/hide');

    final headers = await authHeadersProvider();
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

    final headers = await authHeadersProvider();
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

  Future<CollectionOfferModel> startOffer(int offerId) {
    return _offerAction(offerId, 'start');
  }

  Future<CollectionOfferModel> cancelOffer({
    required int offerId,
    required String reason,
    String? note,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/cancel');

    final headers = await authHeadersProvider();
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
    String? photoPath,
    required double latitude,
    required double longitude,
    double? weightKg,
    String? notes,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/complete');

    if (photoPath != null && photoPath.trim().isNotEmpty) {
      final file = File(photoPath);
      if (!await file.exists()) {
        throw Exception('Completion photo file not found. Please capture again.');
      }
    }

    final token = await tokenProvider();
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

    if (photoPath != null && photoPath.trim().isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to complete offer');
    }

    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<CollectorDashboardModel> getCollectorDashboard(String collectorId) async {
    if (collectorId.isEmpty) {
      throw Exception('Collector ID is empty. Please log in again.');
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyCollectors}/$collectorId/dashboard',
    );

    final headers = await authHeadersProvider();
    final response = await client.get(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load dashboard');
    }

    return CollectorDashboardModel.fromJson(
      body['data'] as Map<String, dynamic>,
    );
  }

  // ─── Public registration endpoints (no auth required) ───

  Future<List<String>> fetchThirdPartyCouncils() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyRegister}/councils',
    );

    final response = await client.get(url, headers: {'Content-Type': 'application/json'});
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to load councils');
    }

    final data = body['data'] as List<dynamic>? ?? const [];
    return data.map((item) => item.toString()).toList();
  }

  Future<String> uploadThirdPartyNicPhoto(File imageFile) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyRegister}/nic-photo',
    );

    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    
    // Log response for debugging
    print('Upload response status: ${response.statusCode}');
    print('Upload response body: ${response.body}');
    
    if (response.body.isEmpty) {
      throw Exception('Server returned empty response');
    }
    
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to upload NIC photo');
    }

    final data = body['data'] as Map<String, dynamic>;
    return data['nicPhotoUrl'] as String;
  }

  Future<Map<String, dynamic>> registerThirdPartyCollector({
    required String empName,
    required String email,
    required String phone,
    required String NIC,
    required String dateOfBirth,
    required String company,
    String? contractId,
    String? contractStart,
    String? contractEnd,
    required String defaultAddress,
    required String idPhotoUrl,
    String? idPhotoBackUrl,
    required String assignedCouncil,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyRegister}',
    );

    final payload = <String, dynamic>{
      'empName': empName,
      'email': email,
      'phone': phone,
      'NIC': NIC,
      'dateOfBirth': dateOfBirth,
      'company': company,
      'defaultAddress': defaultAddress,
      'nicPhotoUrl': idPhotoUrl,
      'nicPhotoBackUrl': idPhotoBackUrl,
      'assignedCouncil': assignedCouncil,
    };
    if (contractId != null) payload['contractId'] = contractId;
    if (contractStart != null) payload['contractStart'] = contractStart;
    if (contractEnd != null) payload['contractEnd'] = contractEnd;

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if ((response.statusCode != 200 && response.statusCode != 201) ||
        body['success'] != true) {
      throw Exception(body['message'] ?? 'Registration failed');
    }

    return body['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkThirdPartyRegistrationStatus(int empId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyRegister}/$empId/status',
    );

    final response = await client.get(url, headers: {'Content-Type': 'application/json'});
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to check status');
    }

    return body['data'] as Map<String, dynamic>;
  }

  Future<void> setThirdPartyPassword({
    required int empId,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.thirdPartyRegister}/$empId/set-password',
    );

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to set password');
    }
  }

  Future<CollectionOfferModel> _offerAction(int offerId, String action) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/$action');
    final headers = await authHeadersProvider();
    final response = await client.post(url, headers: headers);
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to $action offer');
    }

    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}
