class ComplaintModel {
  final int? id;
  final int? assignedPersonnelId;
  final int? citizenId;
  final String? title;
  final String? issueType;
  final String? urgency;
  final String? wasteType;
  final String? council;
  final DateTime? createdAt;
  final String? description;
  final String? imageUrl;
  final String? location;
  final String? resolutionNotes;
  final String? status;
  final bool? isConfirmedTrue;
  final String? fieldStaffNote;
  final String? fieldStaffPhotoUrl;
  final DateTime? updatedAt;

  ComplaintModel({
    this.id,
    this.assignedPersonnelId,
    this.citizenId,
    this.title,
    this.issueType,
    this.urgency,
    this.wasteType,
    this.council,
    this.createdAt,
    this.description,
    this.imageUrl,
    this.location,
    this.resolutionNotes,
    this.status,
    this.isConfirmedTrue,
    this.fieldStaffNote,
    this.fieldStaffPhotoUrl,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      assignedPersonnelId: json['assignedPersonnelId'],
      citizenId: json['citizenId'],
      title: json['title'],
      issueType: json['issueType'],
      urgency: json['urgency'],
      wasteType: json['wasteType'],
      council: json['council'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      description: json['description'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      resolutionNotes: json['resolutionNotes'],
      status: json['status'],
      isConfirmedTrue: json['isConfirmedTrue'],
      fieldStaffNote: json['fieldStaffNote'],
      fieldStaffPhotoUrl: json['fieldStaffPhotoUrl'],
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignedPersonnelId': assignedPersonnelId,
      'citizenId': citizenId,
      'title': title,
      'issueType': issueType,
      'urgency': urgency,
      'wasteType': wasteType,
      'council': council,
      'createdAt': createdAt?.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'resolutionNotes': resolutionNotes,
      'status': status,
      'isConfirmedTrue': isConfirmedTrue,
      'fieldStaffNote': fieldStaffNote,
      'fieldStaffPhotoUrl': fieldStaffPhotoUrl,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Relative time-ago string for display.
  String get timeAgo {
    final timestamp = createdAt ?? updatedAt;
    if (timestamp == null) return 'Recently';
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    return '${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() > 1 ? 's' : ''} ago';
  }

  String get displayId => id != null ? '#$id' : '#--';

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    if (issueType != null && issueType!.trim().isNotEmpty) {
      return issueType!.trim();
    }
    return 'Special Task';
  }

  String get displayIssueType {
    if (issueType != null && issueType!.trim().isNotEmpty) {
      return issueType!.trim();
    }
    return 'General';
  }

  String get displayLocation {
    if (location != null && location!.trim().isNotEmpty) {
      return location!.trim();
    }
    return 'Location not specified';
  }

  String get displayUrgency {
    if (urgency != null && urgency!.trim().isNotEmpty) {
      return urgency!.trim();
    }
    return 'Normal';
  }
}
