import 'collection_offer_model.dart';

class CollectionRequestModel {
  final int id;
  final int citizenId;
  final String citizenName;
  final String wasteType;
  final List<String> wasteTypes;
  final String quantityLabel;
  final double? quantityKgEstimate;
  final String addressLine;
  final double latitude;
  final double longitude;
  final DateTime preferredDate;
  final String preferredSlot;
  final String contactPhone;
  final String? notes;
  final String? photoUrl;
  final String status;
  final int? acceptedOfferId;
  final int offersCount;
  final List<CollectionOfferModel> offers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CollectionRequestModel({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.wasteType,
    this.wasteTypes = const [],
    required this.quantityLabel,
    required this.quantityKgEstimate,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    required this.preferredDate,
    required this.preferredSlot,
    required this.contactPhone,
    required this.notes,
    required this.photoUrl,
    required this.status,
    required this.acceptedOfferId,
    required this.offersCount,
    this.offers = const [],
    this.createdAt,
    this.updatedAt,
  });

  CollectionRequestModel copyWith({
    String? status,
    int? acceptedOfferId,
    int? offersCount,
  }) {
    return CollectionRequestModel(
      id: id,
      citizenId: citizenId,
      citizenName: citizenName,
      wasteType: wasteType,
      wasteTypes: wasteTypes,
      quantityLabel: quantityLabel,
      quantityKgEstimate: quantityKgEstimate,
      addressLine: addressLine,
      latitude: latitude,
      longitude: longitude,
      preferredDate: preferredDate,
      preferredSlot: preferredSlot,
      contactPhone: contactPhone,
      notes: notes,
      photoUrl: photoUrl,
      status: status ?? this.status,
      acceptedOfferId: acceptedOfferId ?? this.acceptedOfferId,
      offersCount: offersCount ?? this.offersCount,
      offers: offers,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }

  factory CollectionRequestModel.fromSummaryJson(Map<String, dynamic> json) {
    return CollectionRequestModel(
      id: (json['id'] as num).toInt(),
      citizenId: (json['citizenId'] as num?)?.toInt() ?? 0,
      citizenName: (json['citizenName'] ?? '').toString(),
      wasteType: (json['wasteType'] ?? '').toString(),
      wasteTypes: _parseWasteTypes(json),
      quantityLabel: (json['quantityLabel'] ?? '').toString(),
      quantityKgEstimate: (json['quantityKgEstimate'] as num?)?.toDouble(),
      addressLine: (json['addressLine'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      preferredDate: DateTime.parse(json['preferredDate'] as String),
      preferredSlot: (json['preferredSlot'] ?? '').toString(),
      contactPhone: (json['contactPhone'] ?? '').toString(),
      notes: json['notes']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      status: (json['status'] ?? '').toString(),
      acceptedOfferId: (json['acceptedOfferId'] as num?)?.toInt(),
      offersCount: (json['offersCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseInstant(json['createdAt']),
      updatedAt: _parseInstant(json['updatedAt']),
    );
  }

  static List<String> _parseWasteTypes(Map<String, dynamic> json) {
    final raw = json['wasteTypes'];
    if (raw is List) {
      return raw.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
    }
    final single = (json['wasteType'] ?? '').toString();
    if (single.isEmpty) return const [];
    return [single];
  }

  static DateTime? _parseInstant(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    try {
      return DateTime.parse(text).toLocal();
    } catch (_) {
      return null;
    }
  }

  factory CollectionRequestModel.fromDetailJson(Map<String, dynamic> json) {
    final request = CollectionRequestModel.fromSummaryJson(
      json['request'] as Map<String, dynamic>,
    );
    final offers = (json['offers'] as List<dynamic>? ?? const [])
        .map(
          (offer) =>
              CollectionOfferModel.fromJson(offer as Map<String, dynamic>),
        )
        .toList();

    return CollectionRequestModel(
      id: request.id,
      citizenId: request.citizenId,
      citizenName: request.citizenName,
      wasteType: request.wasteType,
      wasteTypes: request.wasteTypes,
      quantityLabel: request.quantityLabel,
      quantityKgEstimate: request.quantityKgEstimate,
      addressLine: request.addressLine,
      latitude: request.latitude,
      longitude: request.longitude,
      preferredDate: request.preferredDate,
      preferredSlot: request.preferredSlot,
      contactPhone: request.contactPhone,
      notes: request.notes,
      photoUrl: request.photoUrl,
      status: request.status,
      acceptedOfferId: request.acceptedOfferId,
      offersCount: offers.length,
      offers: offers,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );
  }
}
