class CollectorDashboardModel {
  final int availableRequests;
  final int activeJobs;
  final int completedJobs;
  final double todaysRating;
  final int todaysWorkingMinutes;
  final double todaysWasteCollectedKg;
  final double responseRate;
  final double onTimeRate;
  final double overallRating;

  CollectorDashboardModel({
    required this.availableRequests,
    required this.activeJobs,
    required this.completedJobs,
    required this.todaysRating,
    required this.todaysWorkingMinutes,
    required this.todaysWasteCollectedKg,
    required this.responseRate,
    required this.onTimeRate,
    required this.overallRating,
  });

  factory CollectorDashboardModel.fromJson(Map<String, dynamic> json) {
    return CollectorDashboardModel(
      availableRequests: (json['availableRequests'] as num?)?.toInt() ?? 0,
      activeJobs: (json['activeJobs'] as num?)?.toInt() ?? 0,
      completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
      todaysRating: (json['todaysRating'] as num?)?.toDouble() ?? 0.0,
      todaysWorkingMinutes: (json['todaysWorkingMinutes'] as num?)?.toInt() ?? 0,
      todaysWasteCollectedKg: (json['todaysWasteCollectedKg'] as num?)?.toDouble() ?? 0.0,
      responseRate: (json['responseRate'] as num?)?.toDouble() ?? 0.0,
      onTimeRate: (json['onTimeRate'] as num?)?.toDouble() ?? 0.0,
      overallRating: (json['overallRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
