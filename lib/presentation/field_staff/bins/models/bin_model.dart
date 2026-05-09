/// Data model representing a waste bin assigned to field staff.
///
/// When integrating with the backend API, replace [demoData] with
/// actual API response parsing (e.g. `BinModel.fromJson(json)`).
class BinModel {
  final String id;
  final String location;
  final String address;
  final String category;
  final String displayCode;
  final BinStatus status;
  final int? fillLevel;
  final DateTime? lastChecked;
  final double? latitude;
  final double? longitude;
  final String? assignedToName;

  const BinModel({
    required this.id,
    required this.location,
    required this.address,
    required this.category,
    required this.displayCode,
    this.status = BinStatus.notChecked,
    this.fillLevel,
    this.lastChecked,
    this.latitude,
    this.longitude,
    this.assignedToName,
  });

  String get displayCategory =>
      category.trim().isEmpty ? 'Unknown' : category.trim();

  /// Factory for parsing API JSON responses.
  /// Uncomment and adapt when backend is ready.
  factory BinModel.fromJson(Map<String, dynamic> json) {
    return BinModel(
      id: json['id']?.toString() ?? '',
      location: json['location'] as String? ?? 'Unknown',
      address:
          json['address'] as String? ??
          json['location'] as String? ??
          'Unknown',
      category: json['category']?.toString() ?? '',
      displayCode:
          json['displayCode']?.toString() ?? json['id']?.toString() ?? '',
      status: _parseStatus(json['status'] as String?),
      fillLevel: json['fillLevel'] as int?,
      lastChecked: json['lastChecked'] != null
          ? DateTime.parse(json['lastChecked'] as String)
          : null,
      latitude: (json['lat'] as num?)?.toDouble() ?? (json['latitude'] as num?)?.toDouble(),
      longitude: (json['lng'] as num?)?.toDouble() ?? (json['longitude'] as num?)?.toDouble(),
      assignedToName: json['assignedToName'] as String?,
    );
  }

  static BinStatus _parseStatus(String? status) {
    if (status == null) return BinStatus.notChecked;
    return BinStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => BinStatus.notChecked,
    );
  }

  /// Time-ago string for display.
  String get timeAgo {
    if (lastChecked == null) return 'Not checked today';
    final diff = DateTime.now().difference(lastChecked!);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  // ──────────────────────────────────────────────
  // DEMO DATA REMOVED
  // ──────────────────────────────────────────────
}

enum BinStatus { notChecked, full, half, empty }

extension BinStatusLabel on BinStatus {
  String get label {
    switch (this) {
      case BinStatus.notChecked:
        return 'Not Checked';
      case BinStatus.full:
        return 'Full';
      case BinStatus.half:
        return 'Half';
      case BinStatus.empty:
        return 'Empty';
    }
  }
}
