import 'collection_offer_model.dart';

class CollectionRequestModel {
  final int id;
  final int citizenId;
  final String citizenName;
  final String wasteType;
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

  const CollectionRequestModel({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.wasteType,
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
    );
  }

  factory CollectionRequestModel.fromSummaryJson(Map<String, dynamic> json) {
    return CollectionRequestModel(
      id: (json['id'] as num).toInt(),
      citizenId: (json['citizenId'] as num?)?.toInt() ?? 0,
      citizenName: (json['citizenName'] ?? '').toString(),
      wasteType: (json['wasteType'] ?? '').toString(),
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
    );
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
    );
  }
}
