class DailyPerformancePoint {
  final String date;
  final int totalCollected;
  final int routesDone;
  final double averageRouteTimeSeconds;
  final double efficiencyPercent;
  final int assignedBinsTotal;
  final int missedBinsTotal;

  DailyPerformancePoint({
    required this.date,
    required this.totalCollected,
    required this.routesDone,
    required this.averageRouteTimeSeconds,
    required this.efficiencyPercent,
    required this.assignedBinsTotal,
    required this.missedBinsTotal,
  });

  factory DailyPerformancePoint.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return DailyPerformancePoint(
      date: json['date']?.toString() ?? '',
      totalCollected: toInt(json['totalCollected']),
      routesDone: toInt(json['routesDone']),
      averageRouteTimeSeconds: toDouble(json['averageRouteTimeSeconds']),
      efficiencyPercent: toDouble(json['efficiencyPercent']),
      assignedBinsTotal: toInt(json['assignedBinsTotal']),
      missedBinsTotal: toInt(json['missedBinsTotal']),
    );
  }
}

class CollectorPerformanceStats {
  final int totalCollected;
  final int routesDone;
  final double averageRouteTimeSeconds;
  final double efficiencyPercent;
  final int assignedBinsTotal;
  final int missedBinsTotal;
  final String fromDate;
  final List<DailyPerformancePoint> timeSeries;

  CollectorPerformanceStats({
    required this.totalCollected,
    required this.routesDone,
    required this.averageRouteTimeSeconds,
    required this.efficiencyPercent,
    required this.assignedBinsTotal,
    required this.missedBinsTotal,
    required this.fromDate,
    required this.timeSeries,
  });

  factory CollectorPerformanceStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    final series = (json['timeSeries'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(DailyPerformancePoint.fromJson)
        .toList();

    return CollectorPerformanceStats(
      totalCollected: toInt(json['totalCollected']),
      routesDone: toInt(json['routesDone']),
      averageRouteTimeSeconds: toDouble(json['averageRouteTimeSeconds']),
      efficiencyPercent: toDouble(json['efficiencyPercent']),
      assignedBinsTotal: toInt(json['assignedBinsTotal']),
      missedBinsTotal: toInt(json['missedBinsTotal']),
      fromDate: json['fromDate']?.toString() ?? '',
      timeSeries: series,
    );
  }
}
