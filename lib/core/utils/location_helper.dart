import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> getCurrentPositionOrNull({
    void Function(String message)? onError,
  }) async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        onError?.call('Location services are turned off. Please enable them.');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        onError?.call(
          'Location permission is required. Please allow location access.',
        );
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      onError?.call('Unable to get current location.');
      return null;
    }
  }
}
