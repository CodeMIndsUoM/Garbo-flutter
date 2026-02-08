/// Data models for the Routes feature.

enum RouteStatus { highPriority, pending, completed }

enum BinFillStatus { full, half }

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
