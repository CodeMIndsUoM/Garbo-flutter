class RouteSnapshot {
  final String sessionId;
  final int userId;
  final int version;
  final String status;
  final String? trigger;
  final String? message;
  final List<int> selectedBinIds;
  final List<int> addedBinIds;
  final List<int> removedBinIds;
  final dynamic route;

  const RouteSnapshot({
    required this.sessionId,
    required this.userId,
    required this.version,
    required this.status,
    required this.trigger,
    required this.message,
    required this.selectedBinIds,
    required this.addedBinIds,
    required this.removedBinIds,
    required this.route,
  });

  factory RouteSnapshot.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    List<int> toIntList(dynamic value) {
      if (value is! List) return const [];
      return value.map(toInt).toList(growable: false);
    }

    return RouteSnapshot(
      sessionId: json['sessionId']?.toString() ?? '',
      userId: toInt(json['userId']),
      version: toInt(json['version']),
      status: json['status']?.toString() ?? '',
      trigger: json['trigger']?.toString(),
      message: json['message']?.toString(),
      selectedBinIds: toIntList(json['selectedBinIds']),
      addedBinIds: toIntList(json['addedBinIds']),
      removedBinIds: toIntList(json['removedBinIds']),
      route: json['route'],
    );
  }
}
