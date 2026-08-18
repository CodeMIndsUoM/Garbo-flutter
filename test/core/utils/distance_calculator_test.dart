import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/core/utils/distance_calculator.dart';

/// Reference Haversine implementation using the acos variant
/// (same formula as the backend JPQL query in CollectionRequestRepository.java):
///   6371 * acos(cos(radians(lat1)) * cos(radians(lat2)) *
///              cos(radians(lng2) - radians(lng1)) +
///              sin(radians(lat1)) * sin(radians(lat2)))
double _backendHaversine(double lat1, double lng1, double lat2, double lng2) {
  final toRad = pi / 180;
  final lat1R = lat1 * toRad;
  final lat2R = lat2 * toRad;
  final lng1R = lng1 * toRad;
  final lng2R = lng2 * toRad;
  return 6371.0 *
      acos(
        cos(lat1R) * cos(lat2R) * cos(lng2R - lng1R) +
            sin(lat1R) * sin(lat2R),
      );
}

void main() {
  // ── Core Haversine distance calculation ────────────────────────────────

  group('DistanceCalculator.distanceKm', () {
    test('returns 0 for the same point', () {
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 6.9271, 79.8612);
      expect(d, closeTo(0.0, 0.001));
    });

    test('calculates Colombo to Kandy (~93 km)', () {
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 7.2906, 80.6337);
      expect(d, greaterThan(85));
      expect(d, lessThan(100));
    });

    test('calculates Colombo to Galle (~103 km)', () {
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 6.0535, 80.2210);
      expect(d, greaterThan(95));
      expect(d, lessThan(110));
    });

    test('calculates a very short distance (< 1 km)', () {
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 6.9316, 79.8612);
      expect(d, greaterThan(0.3));
      expect(d, lessThan(1.0));
    });

    test('handles opposite hemispheres', () {
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 40.7128, -74.0060);
      expect(d, greaterThan(13000));
      expect(d, lessThan(15000));
    });

    test('handles negative latitudes (southern hemisphere)', () {
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, -33.8688, 151.2093);
      expect(d, greaterThan(8000));
      expect(d, lessThan(9500));
    });

    test('is symmetric (a->b == b->a)', () {
      final ab =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 7.2906, 80.6337);
      final ba =
          DistanceCalculator.distanceKm(7.2906, 80.6337, 6.9271, 79.8612);
      expect(ab, closeTo(ba, 0.001));
    });

    test('matches Haversine reference for London to Paris (~343 km)', () {
      final d =
          DistanceCalculator.distanceKm(51.5074, -0.1278, 48.8566, 2.3522);
      expect(d, greaterThan(330));
      expect(d, lessThan(355));
    });
  });

  // ── Formatting ─────────────────────────────────────────────────────────

  group('DistanceCalculator.formatDistance', () {
    test('shows metres for distances < 1 km', () {
      expect(DistanceCalculator.formatDistance(0.5), '500 m');
    });

    test('shows metres for very short distances', () {
      expect(DistanceCalculator.formatDistance(0.05), '50 m');
    });

    test('shows kilometres with one decimal for >= 1 km', () {
      expect(DistanceCalculator.formatDistance(3.256), '3.3 km');
    });

    test('shows whole kilometres with .0', () {
      expect(DistanceCalculator.formatDistance(5.0), '5.0 km');
    });

    test('shows 1 km boundary correctly', () {
      expect(DistanceCalculator.formatDistance(0.999), '999 m');
      expect(DistanceCalculator.formatDistance(1.0), '1.0 km');
    });

    test('shows large distances', () {
      expect(DistanceCalculator.formatDistance(42.789), '42.8 km');
    });

    test('rounds metres to nearest integer', () {
      expect(DistanceCalculator.formatDistance(0.8501), '850 m');
    });
  });

  // ── Backend accuracy cross-check ───────────────────────────────────────
  // Verifies the Dart atan2 implementation matches the acos variant used in
  // the backend JPQL query (CollectionRequestRepository.java).

  group('Backend accuracy cross-check (atan2 vs acos)', () {
    final testCases = <String, List<double>>{
      'Colombo to Kandy': [6.9271, 79.8612, 7.2906, 80.6337],
      'Colombo to Galle': [6.9271, 79.8612, 6.0535, 80.2210],
      'Colombo to Jaffna': [6.9271, 79.8612, 9.6615, 80.0255],
      'London to Paris': [51.5074, -0.1278, 48.8566, 2.3522],
      'New York to LA': [40.7128, -74.0060, 34.0522, -118.2437],
      'Tokyo to Seoul': [35.6762, 139.6503, 37.5665, 126.9780],
      'Short (500m)': [6.9271, 79.8612, 6.9316, 79.8612],
    };

    for (final entry in testCases.entries) {
      test('${entry.key}: atan2 matches acos within 0.01 km', () {
        final coords = entry.value;
        final dartResult = DistanceCalculator.distanceKm(
          coords[0],
          coords[1],
          coords[2],
          coords[3],
        );
        final backendResult =
            _backendHaversine(coords[0], coords[1], coords[2], coords[3]);
        expect(
          dartResult,
          closeTo(backendResult, 0.01),
          reason:
              'Dart atan2 (${dartResult.toStringAsFixed(4)} km) vs '
              'backend acos (${backendResult.toStringAsFixed(4)} km) '
              'should differ by < 0.01 km',
        );
      });
    }
  });

  // ── Distance filtering logic (unit test) ───────────────────────────────
  // Validates the same client-side filter logic used in browse.dart

  group('Distance filtering logic', () {
    // Simulates the _filteredRequests logic from browse.dart
    bool passesFilter({
      required double collectorLat,
      required double collectorLng,
      required double requestLat,
      required double requestLng,
      required double maxDistKm,
    }) {
      if (requestLat == 0 && requestLng == 0) return false;
      final km = DistanceCalculator.distanceKm(
        collectorLat,
        collectorLng,
        requestLat,
        requestLng,
      );
      return km <= maxDistKm;
    }

    test('includes request within max distance', () {
      // Two points ~0.5 km apart in Colombo
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 6.9316,
          requestLng: 79.8612,
          maxDistKm: 5.0,
        ),
        isTrue,
      );
    });

    test('excludes request beyond max distance', () {
      // Colombo to Kandy (~93 km) with 10 km limit
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 7.2906,
          requestLng: 80.6337,
          maxDistKm: 10.0,
        ),
        isFalse,
      );
    });

    test('boundary: request at exactly max distance passes', () {
      // Calculate exact distance and use it as the threshold
      final d =
          DistanceCalculator.distanceKm(6.9271, 79.8612, 6.9316, 79.8612);
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 6.9316,
          requestLng: 79.8612,
          maxDistKm: d,
        ),
        isTrue,
      );
    });

    test('excludes request with zero coordinates', () {
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 0.0,
          requestLng: 0.0,
          maxDistKm: 50.0,
        ),
        isFalse,
      );
    });

    test('includes all requests at max slider (50 km) within Sri Lanka', () {
      // Colombo to Negombo (~35 km) - within 50 km
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 7.2089,
          requestLng: 79.8388,
          maxDistKm: 50.0,
        ),
        isTrue,
      );
    });

    test('min slider (1 km) only includes very nearby requests', () {
      // Colombo to point ~0.5 km away - should pass
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 6.9280,
          requestLng: 79.8620,
          maxDistKm: 1.0,
        ),
        isTrue,
      );

      // Colombo to point ~3 km away - should fail
      expect(
        passesFilter(
          collectorLat: 6.9271,
          collectorLng: 79.8612,
          requestLat: 6.9500,
          requestLng: 79.8612,
          maxDistKm: 1.0,
        ),
        isFalse,
      );
    });
  });
}
