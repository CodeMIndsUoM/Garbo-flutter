import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

class BinMapPage extends StatelessWidget {
  final BinModel bin;

  const BinMapPage({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    // Fallback coordinates (e.g. Colombo) if none exist
    final lat = bin.latitude ?? 6.9271;
    final lng = bin.longitude ?? 79.8612;
    final center = LatLng(lat, lng);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.grey900),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bin.displayCode,
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (bin.latitude != null)
              Text(
                '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                style: AppTypography.captionSm.copyWith(
                  color: AppColors.grey600,
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16.0,
              maxZoom: 19.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.garbo.swms',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 60,
                    height: 60,
                    child: _buildBinMarker(),
                  ),
                ],
              ),
            ],
          ),
          Positioned(bottom: 32, left: 24, right: 24, child: _buildInfoCard()),
        ],
      ),
    );
  }

  Widget _buildBinMarker() {
    Color markerColor;
    IconData markerIcon;
    switch (bin.status) {
      case BinStatus.notChecked:
        markerColor = AppColors.grey600;
        markerIcon = Icons.help_outline;
        break;
      case BinStatus.full:
        markerColor = AppColors.red500;
        markerIcon = Icons.sentiment_very_dissatisfied;
        break;
      case BinStatus.half:
        markerColor = AppColors.yellow400;
        markerIcon = Icons.sentiment_neutral;
        break;
      case BinStatus.empty:
        markerColor = AppColors.greenDark;
        markerIcon = Icons.sentiment_satisfied_alt;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: markerColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(markerIcon, color: Colors.white, size: 24),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location Details',
                style: AppTypography.titleSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bin.status.label.toUpperCase(),
                  style: AppTypography.captionSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.greenDark, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bin.address,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.grey700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
