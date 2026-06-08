import 'package:flutter/material.dart';
import 'package:garbo_swms/data/models/citizen_activity_item.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';
import 'package:garbo_swms/data/sources/api_service.dart';

class CitizenRecentActivityLoader {
  const CitizenRecentActivityLoader(this._apiService);

  final ApiService _apiService;

  Future<T> _safeLoad<T>(Future<T> Function() loader, T fallback) async {
    try {
      return await loader();
    } catch (_) {
      return fallback;
    }
  }

  Future<List<CitizenActivityItem>> load({int limit = 5}) async {
    final citizenId = await _apiService.getStoredEmpId();
    final complaints = await _safeLoad(
      _apiService.getMyComplaints,
      <Map<String, dynamic>>[],
    );
    final requests = citizenId.isEmpty
        ? <CollectionRequestModel>[]
        : await _safeLoad(
            () => _apiService.getCitizenCollectionRequests(citizenId),
            <CollectionRequestModel>[],
          );
    final events = await _safeLoad(
      _apiService.getMyEvents,
      <Map<String, dynamic>>[],
    );

    final items = <CitizenActivityItem>[
      ...complaints.map(_fromComplaint),
      ...requests.map(_fromCollectionRequest),
      ...events.map(_fromEvent),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    if (items.length <= limit) return items;
    return items.sublist(0, limit);
  }

  CitizenActivityItem _fromComplaint(Map<String, dynamic> complaint) {
    final status = (complaint['status'] ?? 'PENDING').toString().toUpperCase();
    final issue = (complaint['issueType'] ?? complaint['title'] ?? 'Report')
        .toString();
    final location = (complaint['location'] ?? '').toString();
    final createdAt = _parseDateTime(complaint['createdAt']);
    final updatedAt = _parseDateTime(complaint['updatedAt']);
    final occurredAt = (status == 'PENDING' ? createdAt : updatedAt) ??
        createdAt ??
        DateTime.now();

    return CitizenActivityItem(
      icon: _complaintIcon(status),
      title: _complaintTitle(status),
      subtitle: location.isNotEmpty ? '$issue — $location' : issue,
      occurredAt: occurredAt,
    );
  }

  CitizenActivityItem _fromCollectionRequest(CollectionRequestModel request) {
    final occurredAt =
        request.updatedAt ?? request.createdAt ?? request.preferredDate;
    final waste = _formatLabel(request.wasteType);
    final quantity = request.quantityLabel.trim();

    return CitizenActivityItem(
      icon: _requestIcon(request.status),
      title: _requestTitle(request.status),
      subtitle: quantity.isNotEmpty
          ? '$waste — $quantity'
          : '$waste · ${request.addressLine}',
      occurredAt: occurredAt,
    );
  }

  CitizenActivityItem _fromEvent(Map<String, dynamic> event) {
    final status = (event['status'] ?? 'PENDING').toString().toUpperCase();
    final title = (event['title'] ?? 'Event').toString();
    final eventDate = (event['eventDate'] ?? '').toString();
    final createdAt = _parseDateTime(event['createdAt']);
    final updatedAt = _parseDateTime(event['updatedAt']);
    final occurredAt = (status == 'PENDING_APPROVAL' ? createdAt : updatedAt) ??
        createdAt ??
        DateTime.now();

    final dateLabel = eventDate.isNotEmpty ? eventDate.split('T').first : '';

    return CitizenActivityItem(
      icon: _eventIcon(status),
      title: _eventTitle(status),
      subtitle: dateLabel.isNotEmpty ? '$title on $dateLabel' : title,
      occurredAt: occurredAt,
    );
  }

  static DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    try {
      return DateTime.parse(text).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      final weeks = diff.inDays ~/ 7;
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    final months = diff.inDays ~/ 30;
    return '$months month${months == 1 ? '' : 's'} ago';
  }

  static String _formatLabel(String raw) {
    if (raw.isEmpty) return 'Waste';
    return raw
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static IconData _complaintIcon(String status) {
    switch (status) {
      case 'APPROVED':
      case 'ACCEPTED':
      case 'RESOLVED':
        return Icons.task_alt_rounded;
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.report_outlined;
    }
  }

  static String _complaintTitle(String status) {
    switch (status) {
      case 'APPROVED':
      case 'ACCEPTED':
        return 'Report approved';
      case 'RESOLVED':
        return 'Report resolved';
      case 'REJECTED':
        return 'Report rejected';
      default:
        return 'Report submitted';
    }
  }

  static IconData _requestIcon(String status) {
    switch (status) {
      case 'COMPLETED':
      case 'CONFIRMED':
        return Icons.check_circle_rounded;
      case 'ASSIGNED':
        return Icons.local_shipping_rounded;
      default:
        return Icons.recycling_rounded;
    }
  }

  static String _requestTitle(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Collection completed';
      case 'CONFIRMED':
        return 'Collection confirmed';
      case 'ASSIGNED':
        return 'Pickup assigned';
      case 'CANCELLED':
        return 'Request cancelled';
      default:
        return 'Pickup requested';
    }
  }

  static IconData _eventIcon(String status) {
    switch (status) {
      case 'APPROVED':
      case 'ACTIVE':
        return Icons.event_available_rounded;
      case 'REJECTED':
        return Icons.event_busy_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  static String _eventTitle(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Event approved';
      case 'ACTIVE':
        return 'Event published';
      case 'REJECTED':
        return 'Event suggestion rejected';
      default:
        return 'Event suggestion submitted';
    }
  }
}
