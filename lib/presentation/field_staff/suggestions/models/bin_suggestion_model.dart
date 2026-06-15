class BinSuggestionModel {
  final int id;
  final String? mentorName;
  final String? council;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? category;
  final String? notes;
  final String? imageUrl;
  final String? status;
  final String? resolutionNotes;
  final int? createdBinId;
  final DateTime? createdAt;

  const BinSuggestionModel({
    required this.id,
    this.mentorName,
    this.council,
    this.location,
    this.latitude,
    this.longitude,
    this.category,
    this.notes,
    this.imageUrl,
    this.status,
    this.resolutionNotes,
    this.createdBinId,
    this.createdAt,
  });

  factory BinSuggestionModel.fromJson(Map<String, dynamic> json) {
    return BinSuggestionModel(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      mentorName: json['mentorName'] as String?,
      council: json['council'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String?,
      resolutionNotes: json['resolutionNotes'] as String?,
      createdBinId: json['createdBinId'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  String get displayStatus {
    final normalized = (status ?? 'PENDING').toUpperCase();
    switch (normalized) {
      case 'APPROVED':
      case 'ACCEPTED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  bool get isPending {
    final normalized = (status ?? 'PENDING').toUpperCase();
    return normalized == 'PENDING' || normalized == 'NEW';
  }
}
