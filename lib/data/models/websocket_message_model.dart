class WebSocketMessage<T> {
  final String type;  // AUTH, CONFIRMED, ROUTE_UPDATE, LEADERBOARD_UPDATE, ERROR
  final int? userId;
  final int timestamp;
  final T? payload;
  final String? error;

  WebSocketMessage({
    required this.type,
    this.userId,
    required this.timestamp,
    this.payload,
    this.error,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage<T>(
      type: json['type'] as String,
      userId: json['userId'] as int?,
      timestamp: json['timestamp'] as int,
      payload: json['payload'] as T?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'userId': userId,
    'timestamp': timestamp,
    'payload': payload,
    'error': error,
  };
}

/// Auth handshake payload (client -> server)
class AuthPayload {
  final int userId;

  AuthPayload({required this.userId});

  factory AuthPayload.fromJson(Map<String, dynamic> json) {
    return AuthPayload(userId: json['userId'] as int);
  }

  Map<String, dynamic> toJson() => {'userId': userId};
}

/// Confirmed payload (server -> client)
class ConfirmedPayload {
  final String message;
  final String sessionId;

  ConfirmedPayload({
    required this.message,
    required this.sessionId,
  });

  factory ConfirmedPayload.fromJson(Map<String, dynamic> json) {
    return ConfirmedPayload(
      message: json['message'] as String,
      sessionId: json['sessionId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'sessionId': sessionId,
  };
}

class RouteOptimizeAckPayload {
  final String sessionId;
  final String status;
  final String? message;
  final List<int> selectedBinIds;
  final bool created;

  RouteOptimizeAckPayload({
    required this.sessionId,
    required this.status,
    required this.message,
    required this.selectedBinIds,
    required this.created,
  });

  factory RouteOptimizeAckPayload.fromJson(Map<String, dynamic> json) {
    List<int> toIntList(dynamic value) {
      if (value is! List) {
        return const [];
      }
      return value.map((item) {
        if (item is int) {
          return item;
        }
        if (item is num) {
          return item.toInt();
        }
        return int.tryParse(item.toString()) ?? 0;
      }).toList(growable: false);
    }

    return RouteOptimizeAckPayload(
      sessionId: json['sessionId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString(),
      selectedBinIds: toIntList(json['selectedBinIds']),
      created: json['created'] as bool? ?? false,
    );
  }
}

/// Leaderboard update payload (server -> client)
class LeaderboardUpdatePayload {
  final List<LeaderboardEntryDto> entries;
  final int updatedAt;
  final LeaderboardChangedUserPayload? changedUser;

  LeaderboardUpdatePayload({
    required this.entries,
    required this.updatedAt,
    this.changedUser,
  });

  factory LeaderboardUpdatePayload.fromJson(Map<String, dynamic> json) {
    return LeaderboardUpdatePayload(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LeaderboardEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      updatedAt: json['updatedAt'] as int,
      changedUser: json['changedUser'] == null
          ? null
          : LeaderboardChangedUserPayload.fromJson(
              json['changedUser'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'entries': entries.map((e) => e.toJson()).toList(),
    'updatedAt': updatedAt,
    'changedUser': changedUser?.toJson(),
  };
}

class LeaderboardChangedUserPayload {
  final int userId;
  final String role;
  final int? taskId;
  final String? sourceEventId;
  final int? previousRank;
  final int? currentRank;
  final int? rankDelta;
  final double? previousScore;
  final double? currentScore;
  final double? scoreDelta;
  final bool enteredTop;
  final bool exitedTop;

  LeaderboardChangedUserPayload({
    required this.userId,
    required this.role,
    this.taskId,
    this.sourceEventId,
    this.previousRank,
    this.currentRank,
    this.rankDelta,
    this.previousScore,
    this.currentScore,
    this.scoreDelta,
    required this.enteredTop,
    required this.exitedTop,
  });

  factory LeaderboardChangedUserPayload.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is num) {
        return value.toDouble();
      }
      return double.tryParse(value.toString());
    }

    return LeaderboardChangedUserPayload(
      userId: parseInt(json['userId']) ?? 0,
      role: json['role']?.toString() ?? '',
      taskId: parseInt(json['taskId']),
      sourceEventId: json['sourceEventId']?.toString(),
      previousRank: parseInt(json['previousRank']),
      currentRank: parseInt(json['currentRank']),
      rankDelta: parseInt(json['rankDelta']),
      previousScore: parseDouble(json['previousScore']),
      currentScore: parseDouble(json['currentScore']),
      scoreDelta: parseDouble(json['scoreDelta']),
      enteredTop: json['enteredTop'] as bool? ?? false,
      exitedTop: json['exitedTop'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'role': role,
    'taskId': taskId,
    'sourceEventId': sourceEventId,
    'previousRank': previousRank,
    'currentRank': currentRank,
    'rankDelta': rankDelta,
    'previousScore': previousScore,
    'currentScore': currentScore,
    'scoreDelta': scoreDelta,
    'enteredTop': enteredTop,
    'exitedTop': exitedTop,
  };
}

class LeaderboardEntryDto {
  final int rank;
  final int? userId;
  final String name;
  final double rewardPoints;
  final String role;
  final int? rankChangeFromPrevious;

  LeaderboardEntryDto({
    required this.rank,
    this.userId,
    required this.name,
    required this.rewardPoints,
    required this.role,
    this.rankChangeFromPrevious,
  });

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryDto(
      rank: json['rank'] as int,
      userId: json['userId'] as int?,
      name: json['name'] as String,
      rewardPoints: (json['rewardPoints'] as num).toDouble(),
      role: json['role'] as String,
      rankChangeFromPrevious: json['rankChangeFromPrevious'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'userId': userId,
    'name': name,
    'rewardPoints': rewardPoints,
    'role': role,
    'rankChangeFromPrevious': rankChangeFromPrevious,
  };
}

class BinCollectionAckPayload {
  final int userId;
  final int binId;
  final int totalBinsCollected;
  final int affectedTasks;
  final int updatedAt;

  BinCollectionAckPayload({
    required this.userId,
    required this.binId,
    required this.totalBinsCollected,
    required this.affectedTasks,
    required this.updatedAt,
  });

  factory BinCollectionAckPayload.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return BinCollectionAckPayload(
      userId: toInt(json['userId']),
      binId: toInt(json['binId']),
      totalBinsCollected: toInt(json['totalBinsCollected']),
      affectedTasks: toInt(json['affectedTasks']),
      updatedAt: toInt(json['updatedAt']),
    );
  }
}

class TaskProgressUpdatePayload {
  final int userId;
  final int? binId;
  final int totalBinsCollected;
  final int updatedAt;
  final List<TaskProgressItemPayload> tasks;

  TaskProgressUpdatePayload({
    required this.userId,
    this.binId,
    required this.totalBinsCollected,
    required this.updatedAt,
    required this.tasks,
  });

  factory TaskProgressUpdatePayload.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return TaskProgressUpdatePayload(
      userId: toInt(json['userId']),
      binId: json['binId'] == null ? null : toInt(json['binId']),
      totalBinsCollected: toInt(json['totalBinsCollected']),
      updatedAt: toInt(json['updatedAt']),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskProgressItemPayload.fromJson)
          .toList(),
    );
  }
}

class TaskProgressItemPayload {
  final int taskId;
  final String taskCode;
  final String taskTitle;
  final String taskDescription;
  final double availablePoints;
  final double currentProgress;
  final double targetProgress;
  final bool isCompleted;
  final bool isNew;
  final String? completedAt;
  final double pointsEarned;
  final String? startAt;
  final String? endAt;
  final String? activePeriodLabel;

  TaskProgressItemPayload({
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

  factory TaskProgressItemPayload.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool toBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return TaskProgressItemPayload(
      taskId: toInt(json['taskId']),
      taskCode: json['taskCode']?.toString() ?? '',
      taskTitle: json['taskTitle']?.toString() ?? '',
      taskDescription: json['taskDescription']?.toString() ?? '',
      availablePoints: (json['availablePoints'] as num?)?.toDouble() ?? 0.0,
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
      targetProgress: (json['targetProgress'] as num?)?.toDouble() ?? 1.0,
      isCompleted: toBool(json['isCompleted']),
      isNew: toBool(json['isNew']),
      completedAt: json['completedAt']?.toString(),
      pointsEarned: (json['pointsEarned'] as num?)?.toDouble() ?? 0.0,
      startAt: json['startAt']?.toString(),
      endAt: json['endAt']?.toString(),
      activePeriodLabel: json['activePeriodLabel']?.toString(),
    );
  }
}

/// Route update payload (server -> client)
class RouteUpdatePayload {
  final String sessionId;
  final int? userId;
  final int totalVehiclesUsed;
  final Map<int, VehicleRoute> routes;
  final int updatedAt;

  RouteUpdatePayload({
    required this.sessionId,
    this.userId,
    required this.totalVehiclesUsed,
    required this.routes,
    required this.updatedAt,
  });

  factory RouteUpdatePayload.fromJson(Map<String, dynamic> json) {
    final routesMap = <int, VehicleRoute>{};
    (json['routes'] as Map<String, dynamic>).forEach((key, value) {
      routesMap[int.parse(key)] = VehicleRoute.fromJson(value as Map<String, dynamic>);
    });

    return RouteUpdatePayload(
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as int?,
      totalVehiclesUsed: json['totalVehiclesUsed'] as int,
      routes: routesMap,
      updatedAt: json['updatedAt'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'userId': userId,
    'totalVehiclesUsed': totalVehiclesUsed,
    'routes': routes.map((k, v) => MapEntry(k.toString(), v.toJson())),
    'updatedAt': updatedAt,
  };
}

class VehicleRoute {
  final int vehicleId;
  final int capacity;
  final int totalBins;
  final double estimatedDurationSeconds;
  final List<BinStop> binSequence;

  VehicleRoute({
    required this.vehicleId,
    required this.capacity,
    required this.totalBins,
    required this.estimatedDurationSeconds,
    required this.binSequence,
  });

  factory VehicleRoute.fromJson(Map<String, dynamic> json) {
    return VehicleRoute(
      vehicleId: json['vehicleId'] as int,
      capacity: json['capacity'] as int,
      totalBins: json['totalBins'] as int,
      estimatedDurationSeconds: (json['estimatedDurationSeconds'] as num).toDouble(),
      binSequence: (json['binSequence'] as List<dynamic>)
          .map((e) => BinStop.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicleId': vehicleId,
    'capacity': capacity,
    'totalBins': totalBins,
    'estimatedDurationSeconds': estimatedDurationSeconds,
    'binSequence': binSequence.map((e) => e.toJson()).toList(),
  };
}

class BinStop {
  final int stopOrder;
  final int binId;
  final double lat;
  final double lng;
  final double durationFromPrevStopSeconds;
  final String? address;

  BinStop({
    required this.stopOrder,
    required this.binId,
    required this.lat,
    required this.lng,
    required this.durationFromPrevStopSeconds,
    this.address,
  });

  factory BinStop.fromJson(Map<String, dynamic> json) {
    return BinStop(
      stopOrder: json['stopOrder'] as int,
      binId: json['binId'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      durationFromPrevStopSeconds: (json['durationFromPrevStopSeconds'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'stopOrder': stopOrder,
    'binId': binId,
    'lat': lat,
    'lng': lng,
    'durationFromPrevStopSeconds': durationFromPrevStopSeconds,
    'address': address,
  };
}
