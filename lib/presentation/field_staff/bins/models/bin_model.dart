/// Data model representing a waste bin assigned to field staff.
///
/// When integrating with the backend API, replace [demoData] with
/// actual API response parsing (e.g. `BinModel.fromJson(json)`).
class BinModel {
  final String id;
  final String location;
  final String address;
  final BinCategory category;
  final BinStatus status;
  final int? fillLevel;
  final DateTime? lastChecked;

  const BinModel({
    required this.id,
    required this.location,
    required this.address,
    required this.category,
    this.status = BinStatus.notChecked,
    this.fillLevel,
    this.lastChecked,
  });

  /// Factory for parsing API JSON responses.
  /// Uncomment and adapt when backend is ready.
  factory BinModel.fromJson(Map<String, dynamic> json) {
    return BinModel(
      id: json['id'] as String? ?? '',
      location: json['location'] as String? ?? 'Unknown',
      address:
          json['address'] as String? ??
          json['location'] as String? ??
          'Unknown',
      category: _parseCategory(json['category'] as String?),
      status: _parseStatus(json['status'] as String?),
      fillLevel: json['fillLevel'] as int?,
      lastChecked: json['lastChecked'] != null
          ? DateTime.parse(json['lastChecked'] as String)
          : null,
    );
  }

  static BinCategory _parseCategory(String? category) {
    if (category == null) return BinCategory.public;
    return BinCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == category.toLowerCase(),
      orElse: () => BinCategory.public,
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

enum BinCategory { public, park, commercial, medical, education }

extension BinCategoryLabel on BinCategory {
  String get label {
    switch (this) {
      case BinCategory.public:
        return 'Public';
      case BinCategory.park:
        return 'Park';
      case BinCategory.commercial:
        return 'Commercial';
      case BinCategory.medical:
        return 'Medical';
      case BinCategory.education:
        return 'Education';
    }
  }
}
