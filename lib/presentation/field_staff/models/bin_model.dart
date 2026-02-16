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
  // factory BinModel.fromJson(Map<String, dynamic> json) {
  //   return BinModel(
  //     id: json['id'] as String,
  //     location: json['location'] as String,
  //     address: json['address'] as String,
  //     category: BinCategory.values.firstWhere(
  //       (e) => e.name == json['category'],
  //       orElse: () => BinCategory.public,
  //     ),
  //     status: BinStatus.values.firstWhere(
  //       (e) => e.name == json['status'],
  //       orElse: () => BinStatus.notChecked,
  //     ),
  //     fillLevel: json['fillLevel'] as int?,
  //     lastChecked: json['lastChecked'] != null
  //         ? DateTime.parse(json['lastChecked'] as String)
  //         : null,
  //   );
  // }

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
  // DEMO DATA — Remove this block when connecting
  // to the backend API.
  // ──────────────────────────────────────────────
  static final List<BinModel> demoData = [
    const BinModel(
      id: 'BIN-001',
      location: 'Main Street Plaza',
      address: '123 Main St',
      category: BinCategory.public,
      status: BinStatus.notChecked,
    ),
    BinModel(
      id: 'BIN-002',
      location: 'Central Park',
      address: '45 Park Ave',
      category: BinCategory.park,
      status: BinStatus.full,
      fillLevel: 100,
      lastChecked: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    BinModel(
      id: 'BIN-003',
      location: 'Market Square',
      address: '78 Market Rd',
      category: BinCategory.commercial,
      status: BinStatus.half,
      fillLevel: 50,
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    BinModel(
      id: 'BIN-004',
      location: 'Shopping Mall',
      address: '90 Shop Ln',
      category: BinCategory.commercial,
      status: BinStatus.half,
      fillLevel: 45,
      lastChecked: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    BinModel(
      id: 'BIN-006',
      location: 'Library',
      address: '15 Book St',
      category: BinCategory.public,
      status: BinStatus.empty,
      fillLevel: 5,
      lastChecked: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    const BinModel(
      id: 'BIN-007',
      location: 'Hospital',
      address: '200 Health Ave',
      category: BinCategory.medical,
      status: BinStatus.notChecked,
    ),
    BinModel(
      id: 'BIN-008',
      location: 'School Zone',
      address: '50 Education Rd',
      category: BinCategory.education,
      status: BinStatus.half,
      fillLevel: 55,
      lastChecked: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BinModel(
      id: 'BIN-005',
      location: 'Bus Terminal',
      address: '300 Transit Ave',
      category: BinCategory.public,
      status: BinStatus.full,
      fillLevel: 90,
      lastChecked: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];
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
