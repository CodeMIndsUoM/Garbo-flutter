class CollectionOfferModel {
  final int id;
  final int requestId;
  final int collectorId;
  final String collectorName;
  final String? collectorCompany;
  final double pricePerUnit;
  final String priceUnit;
  final DateTime proposedPickupAt;
  final String? messageToCitizen;
  final String status;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final int? citizenRating;
  final String? citizenFeedback;
  final String? completionPhotoUrl;

  const CollectionOfferModel({
    required this.id,
    required this.requestId,
    required this.collectorId,
    required this.collectorName,
    required this.collectorCompany,
    required this.pricePerUnit,
    required this.priceUnit,
    required this.proposedPickupAt,
    required this.messageToCitizen,
    required this.status,
    required this.completedAt,
    required this.createdAt,
    required this.citizenRating,
    required this.citizenFeedback,
    required this.completionPhotoUrl,
  });

  factory CollectionOfferModel.fromJson(Map<String, dynamic> json) {
    return CollectionOfferModel(
      id: (json['id'] as num).toInt(),
      requestId: (json['requestId'] as num).toInt(),
      collectorId: (json['collectorId'] as num).toInt(),
      collectorName: (json['collectorName'] ?? 'Collector').toString(),
      collectorCompany: json['collectorCompany']?.toString(),
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0,
      priceUnit: (json['priceUnit'] ?? 'FIXED').toString(),
      proposedPickupAt: DateTime.parse(json['proposedPickupAt'] as String),
      messageToCitizen: json['messageToCitizen']?.toString(),
      status: (json['status'] ?? '').toString(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      citizenRating: (json['citizenRating'] as num?)?.toInt(),
      citizenFeedback: json['citizenFeedback']?.toString(),
      completionPhotoUrl: json['completionPhotoUrl']?.toString(),
    );
  }
}
