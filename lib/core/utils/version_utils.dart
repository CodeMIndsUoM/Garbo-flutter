/// Compares dotted semantic version strings (e.g. 1.0.0 vs 1.0.1).
/// Returns negative if [a] < [b], zero if equal, positive if [a] > [b].
int compareVersions(String a, String b) {
  final aParts = _parseVersionParts(a);
  final bParts = _parseVersionParts(b);
  final length = aParts.length > bParts.length ? aParts.length : bParts.length;

  for (var i = 0; i < length; i++) {
    final aPart = i < aParts.length ? aParts[i] : 0;
    final bPart = i < bParts.length ? bParts[i] : 0;
    if (aPart != bPart) {
      return aPart.compareTo(bPart);
    }
  }
  return 0;
}

bool isUpdateAvailable(String currentVersion, String latestVersion) {
  return compareVersions(currentVersion, latestVersion) < 0;
}

List<int> _parseVersionParts(String version) {
  final normalized = version.split('+').first.trim();
  if (normalized.isEmpty) return [0];

  return normalized.split('.').map((part) {
    final digits = RegExp(r'^\d+').stringMatch(part);
    return int.tryParse(digits ?? '0') ?? 0;
  }).toList();
}
