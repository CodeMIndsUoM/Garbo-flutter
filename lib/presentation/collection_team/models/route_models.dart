/// Data models for the Routes feature.

enum RouteStatus { highPriority, pending, completed }

enum BinFillStatus { full, half }

/// Collection status for each individual bin within a route.
enum BinCollectionStatus { pending, collecting, collected, skipped }

class RouteData {
  final String id;
  final String name;
  final int bins;
  final double distance;
  final int duration;
  final int progress;
  final int totalBins;
  final RouteStatus status;

  const RouteData({
    required this.id,
    required this.name,
    required this.bins,
    required this.distance,
    required this.duration,
    required this.progress,
    required this.totalBins,
    required this.status,
  });

  /// Create a copy with updated fields.
  RouteData copyWith({
    String? id,
    String? name,
    int? bins,
    double? distance,
    int? duration,
    int? progress,
    int? totalBins,
    RouteStatus? status,
  }) {
    return RouteData(
      id: id ?? this.id,
      name: name ?? this.name,
      bins: bins ?? this.bins,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      totalBins: totalBins ?? this.totalBins,
      status: status ?? this.status,
    );
  }
}

class BinData {
  final String id;
  final String name;
  final String address;
  final double distance;
  final int duration;
  final BinFillStatus fillStatus;
  final bool isUrgent;
  final double? nextDistance;
  final int? nextEta;

  const BinData({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.duration,
    required this.fillStatus,
    required this.isUrgent,
    this.nextDistance,
    this.nextEta,
  });
}
