/// Pure helper functions for the My Jobs page.
library;

/// Formats a [DateTime] as `yyyy-MM-dd HH:mm`.
String formatPickup(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

/// Returns a relative time label like "3 min ago" or "in 2 hrs".
String postedAgoLabel(DateTime? dateTime) {
  if (dateTime == null) return 'unknown';

  final diff = DateTime.now().difference(dateTime.toLocal());
  if (diff.isNegative) {
    final ahead = diff.abs();
    if (ahead.inMinutes < 1) return 'soon';
    if (ahead.inHours < 1) return 'in ${ahead.inMinutes} min';
    if (ahead.inDays < 1) return 'in ${ahead.inHours} hrs';
    return 'in ${ahead.inDays} days';
  }

  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hrs ago';
  return '${diff.inDays} days ago';
}

/// Whether a weight value is required for the given waste type.
bool weightRequired(String wasteType) {
  final normalized = wasteType
      .trim()
      .toUpperCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  return const {'METAL', 'E_WASTE', 'PAPER', 'ORGANIC'}.contains(normalized);
}
