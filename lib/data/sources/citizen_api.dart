import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:garbo_swms/core/constants/api_constants.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';

typedef AuthHeadersProvider = Future<Map<String, String>> Function();
typedef TokenProvider = Future<String> Function();

class CitizenApi {
  final http.Client client;
  final AuthHeadersProvider authHeadersProvider;
  final TokenProvider tokenProvider;

  CitizenApi({
    required this.client,
    required this.authHeadersProvider,
    required this.tokenProvider,
  });

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

    final headers = await authHeadersProvider();
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

  Future<CollectionRequestModel> getCollectionRequestDetail(int requestId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.collectionRequests}/$requestId',
    );

    final headers = await authHeadersProvider();
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

    final headers = await authHeadersProvider();
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

    final token = await tokenProvider();
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

  Future<CollectionOfferModel> confirmOffer({
    required int offerId,
    required int rating,
    String? feedback,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.offers}/$offerId/confirm',
    );
    final headers = await authHeadersProvider();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode({'rating': rating, 'feedback': feedback}),
    );
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Failed to confirm offer');
    }
    return CollectionOfferModel.fromJson(body['data'] as Map<String, dynamic>);
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
