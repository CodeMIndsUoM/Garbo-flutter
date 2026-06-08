class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      read: json['read'] == true || json['isRead'] == true,
      createdAt: _parseDate(json['createdAt'] ?? json['timestamp']),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }

  factory AppNotificationModel.fromRemoteMessage({
    required String messageId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    return AppNotificationModel(
      id: messageId,
      title: title,
      body: body,
      type: data['type']?.toString() ?? 'PUSH',
      read: false,
      createdAt: DateTime.now(),
      data: data.isEmpty ? null : data,
    );
  }

  AppNotificationModel copyWith({bool? read}) {
    return AppNotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
      data: data,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      final ms = value > 9999999999 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
