import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';

/// Returns display labels for all selected waste types on a request.
List<String> wasteTypeLabels(CollectionRequestModel request) {
  final rawTypes =
      request.wasteTypes.isNotEmpty ? request.wasteTypes : [request.wasteType];
  return rawTypes
      .where((type) => type.isNotEmpty)
      .map((type) => type.replaceAll('_', ' '))
      .toList();
}

String wasteTypesLabel(CollectionRequestModel request) {
  final labels = wasteTypeLabels(request);
  if (labels.isEmpty) return 'Waste';
  return labels.join(', ');
}

/// Maps a user-facing waste-type label to its API enum value.
String mapWasteType(String value) {
  switch (value) {
    case 'Plastic':
      return 'PLASTIC';
    case 'Glass':
      return 'GLASS';
    case 'Metal':
      return 'METAL';
    case 'E-Waste':
      return 'E_WASTE';
    case 'Paper':
      return 'PAPER';
    case 'Organic':
      return 'ORGANIC';
    case 'Textile':
      return 'TEXTILE';
    default:
      return 'MIXED';
  }
}

/// Maps a user-facing time-slot label to its API enum value.
String mapTimeSlot(String value) {
  if (value.startsWith('Morning')) return 'MORNING';
  if (value.startsWith('Afternoon')) return 'AFTERNOON';
  return 'EVENING';
}

/// Formats a [DateTime] as `yyyy-MM-dd` for the API.
String formatRequestDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Returns the appropriate icon for a given waste-type API value.
IconData iconForWasteType(String wasteType) {
  switch (wasteType) {
    case 'E_WASTE':
      return Icons.electrical_services_rounded;
    case 'METAL':
      return Icons.precision_manufacturing_outlined;
    case 'ORGANIC':
      return Icons.eco_outlined;
    case 'PAPER':
      return Icons.description_outlined;
    case 'TEXTILE':
      return Icons.checkroom_outlined;
    case 'GLASS':
      return Icons.wine_bar_outlined;
    default:
      return Icons.delete_outline_rounded;
  }
}

/// Returns background color, text color, and label for a request status.
({Color bg, Color text, String label}) statusStyle(String status) {
  switch (status) {
    case 'OPEN':
      return (
        bg: AppColors.orange200,
        text: AppColors.orange600,
        label: 'open',
      );
    case 'ASSIGNED':
      return (
        bg: AppColors.blue200,
        text: AppColors.blue600,
        label: 'assigned',
      );
    case 'COMPLETED':
    case 'CONFIRMED':
      return (
        bg: AppColors.emerald200,
        text: AppColors.emerald900,
        label: status.toLowerCase(),
      );
    case 'CANCELLED':
      return (
        bg: AppColors.grey200,
        text: AppColors.grey700,
        label: 'cancelled',
      );
    default:
      return (
        bg: AppColors.grey200,
        text: AppColors.grey700,
        label: status.toLowerCase(),
      );
  }
}

/// Returns a human-readable subtitle for a collection request card.
String requestSubtitle(CollectionRequestModel request) {
  if (request.status == 'OPEN' && request.offersCount > 0) {
    return '${request.offersCount} offer${request.offersCount == 1 ? '' : 's'} available';
  }
  if (request.status == 'ASSIGNED') {
    return 'Collector selected';
  }
  if (request.status == 'CONFIRMED') {
    return 'Collection confirmed';
  }
  return request.addressLine;
}
