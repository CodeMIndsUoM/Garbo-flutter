import 'dart:math';

/// Haversine formula to compute the great‑circle distance in kilometres
/// between two GPS coordinates on Earth.
///
/// Reference: https://en.wikipedia.org/wiki/Haversine_formula
class DistanceCalculator {
  DistanceCalculator._();

  /// Earth's mean radius in kilometres.
  static const double earthRadiusKm = 6371.0;

  /// Returns the distance in **kilometres** between [lat1],[lng1] and
  /// [lat2],[lng2] using the Haversine formula.
  ///
  /// All arguments are in **degrees** (standard GPS format).
  static double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Returns a human‑readable distance label.
  ///
  /// * < 1 km  → e.g. "850 m"
  /// * >= 1 km → e.g. "3.2 km"
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      final metres = (distanceKm * 1000).round();
      return '$metres m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
