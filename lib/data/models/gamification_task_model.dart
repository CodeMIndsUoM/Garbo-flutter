class GamificationTaskDto {
  final int id;
  final String code;
  final String title;
  final String description;
  final String roleScope; // COLLECTOR, FIELD_MENTOR, ALL
  final String taskType;
  final String scoringType; // FIXED, PRIORITY_WEIGHTED
  final double basePoints;
  final double highPriorityMultiplier;
  final double mediumPriorityMultiplier;
  final String status; // DRAFT, PUBLISHED, PAUSED, ARCHIVED
  final String? startAt;
  final String? endAt;
  final String createdAt;
  final String updatedAt;

  GamificationTaskDto({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.roleScope,
    required this.taskType,
    required this.scoringType,
    required this.basePoints,
    required this.highPriorityMultiplier,
    required this.mediumPriorityMultiplier,
    required this.status,
    this.startAt,
    this.endAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GamificationTaskDto.fromJson(Map<String, dynamic> json) {
    return GamificationTaskDto(
      id: json['id'] as int? ?? 0,
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      roleScope: json['roleScope']?.toString() ?? 'COLLECTOR',
      taskType: json['taskType']?.toString() ?? '',
      scoringType: json['scoringType']?.toString() ?? 'FIXED',
      basePoints: (json['basePoints'] as num?)?.toDouble() ?? 0.0,
      highPriorityMultiplier: (json['highPriorityMultiplier'] as num?)?.toDouble() ?? 1.5,
      mediumPriorityMultiplier: (json['mediumPriorityMultiplier'] as num?)?.toDouble() ?? 1.2,
      status: json['status']?.toString() ?? 'DRAFT',
      startAt: json['startAt']?.toString(),
      endAt: json['endAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'description': description,
    'roleScope': roleScope,
    'taskType': taskType,
    'scoringType': scoringType,
    'basePoints': basePoints,
    'highPriorityMultiplier': highPriorityMultiplier,
    'mediumPriorityMultiplier': mediumPriorityMultiplier,
    'status': status,
    'startAt': startAt,
    'endAt': endAt,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  bool get isActive => status == 'PUBLISHED';
  bool get isArchived => status == 'ARCHIVED';
}

/// User progress on a gamification task
class UserTaskProgress {
  final int userId;
  final int taskId;
  final String taskCode;
  final String taskTitle;
  final String taskDescription;
  final double availablePoints;
  final double currentProgress; // 0.0 to 100.0 for percentage, or actual count
  final double targetProgress; // Target value (e.g., 100 bins)
  final bool isCompleted;
  final bool isNew;
  final String? completedAt;
  final double pointsEarned;
  final String? startAt;
  final String? endAt;
  final String? activePeriodLabel;

  UserTaskProgress({
    required this.userId,
    required this.taskId,
    required this.taskCode,
    required this.taskTitle,
    required this.taskDescription,
    required this.availablePoints,
    required this.currentProgress,
    required this.targetProgress,
    required this.isCompleted,
    required this.isNew,
    this.completedAt,
    required this.pointsEarned,
    this.startAt,
    this.endAt,
    this.activePeriodLabel,
  });

  factory UserTaskProgress.fromJson(Map<String, dynamic> json) {
    final completedValue = json.containsKey('isCompleted')
        ? json['isCompleted']
        : json['completed'];

    return UserTaskProgress(
      userId: json['userId'] as int? ?? 0,
      taskId: json['taskId'] as int? ?? 0,
      taskCode: json['taskCode']?.toString() ?? '',
      taskTitle: json['taskTitle']?.toString() ?? '',
      taskDescription: json['taskDescription']?.toString() ?? '',
      availablePoints: (json['availablePoints'] as num?)?.toDouble() ?? 0.0,
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      targetProgress: (json['targetProgress'] as num?)?.toDouble() ?? 100.0,
      isCompleted: completedValue as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      completedAt: json['completedAt']?.toString(),
      pointsEarned: (json['pointsEarned'] as num?)?.toDouble() ?? 0.0,
      startAt: json['startAt']?.toString(),
      endAt: json['endAt']?.toString(),
      activePeriodLabel: json['activePeriodLabel']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'taskId': taskId,
    'taskCode': taskCode,
    'taskTitle': taskTitle,
    'taskDescription': taskDescription,
    'availablePoints': availablePoints,
    'currentProgress': currentProgress,
    'targetProgress': targetProgress,
    'isCompleted': isCompleted,
    'isNew': isNew,
    'completedAt': completedAt,
    'pointsEarned': pointsEarned,
    'startAt': startAt,
    'endAt': endAt,
    'activePeriodLabel': activePeriodLabel,
  };

  double get progressPercentage =>
      targetProgress > 0 ? (currentProgress / targetProgress * 100).clamp(0, 100) : 0;
}
