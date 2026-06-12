import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:garbo_swms/core/map/silent_network_tile_provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:latlong2/latlong.dart';

/// Compact read-only map showing a selected point.
class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({
    super.key,
    required this.location,
    this.height = 180,
    this.onTap,
  });

  final LatLng location;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final map = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location,
            initialZoom: 16,
            minZoom: 3,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: SilentNetworkTileProvider(),
              userAgentPackageName: 'com.garbo.swms',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 48,
                  height: 48,
                  child: const Icon(
                    Icons.location_pin,
                    color: AppColors.red500,
                    size: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return map;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            map,
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_location_alt_outlined,
                        size: 16, color: AppColors.green700),
                    const SizedBox(width: 4),
                    Text(
                      'Adjust',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.green700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
