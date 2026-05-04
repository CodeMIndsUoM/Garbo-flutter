import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:garbo_swms/data/models/collection_offer_model.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/models/collector_dashboard_model.dart';
import 'package:garbo_swms/data/sources/citizen_api.dart';
import 'package:garbo_swms/data/sources/field_staff_api.dart';
import 'package:garbo_swms/data/sources/profile_api.dart';
import 'package:garbo_swms/data/sources/third_party_collector_api.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

class ApiService {
  final http.Client client;
  late final FieldStaffApi _fieldStaffApi;
  late final ProfileApi _profileApi;
  late final CitizenApi _citizenApi;
  late final ThirdPartyCollectorApi _thirdPartyCollectorApi;

  ApiService({http.Client? client}) : client = client ?? http.Client() {
    _fieldStaffApi = FieldStaffApi(
      client: this.client,
      authHeadersProvider: _authHeaders,
      tokenProvider: _accessToken,
    );
    _profileApi = ProfileApi(
      client: this.client,
      authHeadersProvider: _authHeaders,
      tokenProvider: _accessToken,
    );
    _citizenApi = CitizenApi(
      client: this.client,
      authHeadersProvider: _authHeaders,
      tokenProvider: _accessToken,
    );
    _thirdPartyCollectorApi = ThirdPartyCollectorApi(
      client: this.client,
      authHeadersProvider: _authHeaders,
      tokenProvider: _accessToken,
    );
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _accessToken();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<String> _accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<List<BinModel>> getAssignedBins() => _fieldStaffApi.getAssignedBins();

  Future<bool> reportBinStatus({
    required String binId,
    required Map<String, dynamic> reportData,
    String? photoPath,
  }) => _fieldStaffApi.reportBinStatus(
    binId: binId,
    reportData: reportData,
    photoPath: photoPath,
  );

  Future<bool> undoBinReport(String binId) =>
      _fieldStaffApi.undoBinReport(binId);

  Future<String> getFieldMentorName(String empId) =>
      _profileApi.getFieldMentorName(empId);

  Future<String> getStoredEmpId() => _profileApi.getStoredEmpId();

  Future<String> getStoredEmpName() => _profileApi.getStoredEmpName();

  Future<Map<String, dynamic>?> getUserProfile(String userId) =>
      _profileApi.getUserProfile(userId);

  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) =>
      _profileApi.updateUserProfile(userId, data);

  Future<Map<String, dynamic>?> getThirdPartyCollectorProfile(
    String collectorId,
  ) => _profileApi.getThirdPartyCollectorProfile(collectorId);

  Future<bool> updateThirdPartyCollectorProfile(
    String collectorId,
    Map<String, dynamic> data,
  ) => _profileApi.updateThirdPartyCollectorProfile(collectorId, data);

  Future<String?> uploadProfilePicture(String userId, File imageFile) =>
      _profileApi.uploadProfilePicture(userId, imageFile);

  Future<List<CollectionRequestModel>> getCitizenCollectionRequests(
    String citizenId, {
    String? status,
  }) => _citizenApi.getCitizenCollectionRequests(citizenId, status: status);

  Future<CollectionRequestModel> getCollectionRequestDetail(int requestId) =>
      _citizenApi.getCollectionRequestDetail(requestId);

  Future<CollectionRequestModel> createCollectionRequest({
    required String citizenId,
    required Map<String, dynamic> payload,
  }) => _citizenApi.createCollectionRequest(
    citizenId: citizenId,
    payload: payload,
  );

  Future<String> uploadCitizenRequestPhoto({
    required String citizenId,
    required String photoPath,
  }) => _citizenApi.uploadCitizenRequestPhoto(
    citizenId: citizenId,
    photoPath: photoPath,
  );

  Future<CollectionOfferModel> acceptOffer(int offerId) =>
      _citizenApi.acceptOffer(offerId);

  Future<CollectionOfferModel> rejectOffer(int offerId) =>
      _citizenApi.rejectOffer(offerId);

  Future<CollectionOfferModel> confirmOffer({
    required int offerId,
    required int rating,
    String? feedback,
  }) => _citizenApi.confirmOffer(
    offerId: offerId,
    rating: rating,
    feedback: feedback,
  );

  Future<List<CollectionRequestModel>> getCollectorFeed(
    String collectorId, {
    double? lat,
    double? lng,
  }) => _thirdPartyCollectorApi.getCollectorFeed(
    collectorId,
    lat: lat,
    lng: lng,
  );

  Future<CollectionOfferModel> sendCollectorOffer({
    required int requestId,
    required Map<String, dynamic> payload,
  }) => _thirdPartyCollectorApi.sendCollectorOffer(
    requestId: requestId,
    payload: payload,
  );

  Future<List<CollectionOfferModel>> getCollectorOffers(
    String collectorId, {
    String? status,
  }) => _thirdPartyCollectorApi.getCollectorOffers(collectorId, status: status);

  Future<List<CollectionOfferModel>> getCollectorActiveJobs(String collectorId) =>
      _thirdPartyCollectorApi.getCollectorActiveJobs(collectorId);

  Future<CollectionOfferModel> withdrawOffer(int offerId) =>
      _thirdPartyCollectorApi.withdrawOffer(offerId);

  Future<void> hideOffer(int offerId) => _thirdPartyCollectorApi.hideOffer(offerId);

  Future<int> hideCollectorOffers({
    required String collectorId,
    List<String>? statuses,
  }) => _thirdPartyCollectorApi.hideCollectorOffers(
    collectorId: collectorId,
    statuses: statuses,
  );

  Future<CollectionOfferModel> startOffer(int offerId) =>
      _thirdPartyCollectorApi.startOffer(offerId);

  Future<CollectionOfferModel> cancelOffer({
    required int offerId,
    required String reason,
    String? note,
  }) => _thirdPartyCollectorApi.cancelOffer(
    offerId: offerId,
    reason: reason,
    note: note,
  );

  Future<CollectionOfferModel> completeOffer({
    required int offerId,
    String? photoPath,
    required double latitude,
    required double longitude,
    double? weightKg,
    String? notes,
  }) => _thirdPartyCollectorApi.completeOffer(
    offerId: offerId,
    photoPath: photoPath,
    latitude: latitude,
    longitude: longitude,
    weightKg: weightKg,
    notes: notes,
  );

  Future<CollectorDashboardModel> getCollectorDashboard(String collectorId) =>
      _thirdPartyCollectorApi.getCollectorDashboard(collectorId);

  // ─── Third-party collector registration (public, no auth) ───

  Future<List<String>> fetchThirdPartyCouncils() =>
      _thirdPartyCollectorApi.fetchThirdPartyCouncils();

  Future<String> uploadThirdPartyNicPhoto(File imageFile) =>
      _thirdPartyCollectorApi.uploadThirdPartyNicPhoto(imageFile);

  Future<Map<String, dynamic>> registerThirdPartyCollector({
    required String empName,
    required String email,
    required String phone,
    required String NIC,
    required String dateOfBirth,
    String? company,
    String? contractId,
    String? contractStart,
    String? contractEnd,
    required String defaultAddress,
    required String idPhotoUrl,
    String? idPhotoBackUrl,
    required List<String> assignedCouncils,
  }) => _thirdPartyCollectorApi.registerThirdPartyCollector(
    empName: empName,
    email: email,
    phone: phone,
    NIC: NIC,
    dateOfBirth: dateOfBirth,
    company: company,
    contractId: contractId,
    contractStart: contractStart,
    contractEnd: contractEnd,
    defaultAddress: defaultAddress,
    idPhotoUrl: idPhotoUrl,
    idPhotoBackUrl: idPhotoBackUrl,
    assignedCouncils: assignedCouncils,
  );

  Future<Map<String, dynamic>> checkThirdPartyRegistrationStatus(int empId) =>
      _thirdPartyCollectorApi.checkThirdPartyRegistrationStatus(empId);

  Future<void> setThirdPartyPassword({
    required int empId,
    required String email,
    required String password,
  }) => _thirdPartyCollectorApi.setThirdPartyPassword(
    empId: empId,
    email: email,
    password: password,
  );
}
