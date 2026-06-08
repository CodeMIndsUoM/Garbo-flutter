import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:garbo_swms/core/map/silent_network_tile_provider.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';
import 'package:garbo_swms/core/utils/location_helper.dart';
import 'package:latlong2/latlong.dart';

class PickupLocationPickerPage extends StatefulWidget {
  final LatLng initialLocation;
  final String initialAddress;
  final String appBarTitle;
  final String instructions;
  final String confirmLabel;

  const PickupLocationPickerPage({
    super.key,
    required this.initialLocation,
    this.initialAddress = '',
    this.appBarTitle = 'Choose Pickup Location',
    this.instructions = 'Place the pin where the waste will be collected.',
    this.confirmLabel = 'Confirm Pickup Location',
  });

  @override
  State<PickupLocationPickerPage> createState() =>
      _PickupLocationPickerPageState();
}

class _PickupLocationPickerPageState extends State<PickupLocationPickerPage> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation;
  bool _resolvingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _resolvingCurrentLocation = true);
    try {
      final position = await LocationHelper.getCurrentPositionOrNull(
        onError: _showSnackBar,
      );
      if (position == null || !mounted) return;

      final location = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = location);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(location, 16);
        }
      });
    } catch (e) {
      _showSnackBar('Could not get current location: $e');
    } finally {
      if (mounted) {
        setState(() => _resolvingCurrentLocation = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.emerald600,
        foregroundColor: Colors.white,
        title: Text(widget.appBarTitle),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.instructions,
                  style: AppTypography.titleMd,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.initialAddress.isEmpty
                      ? 'Tap on the map to adjust the pickup point.'
                      : 'Address: ${widget.initialAddress}',
                  style: AppTypography.bodySm,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 15,
                    minZoom: 3,
                    maxZoom: 19,
                    onTap: (_, point) {
                      setState(() => _selectedLocation = point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: SilentNetworkTileProvider(),
                      userAgentPackageName: 'com.garbo.swms',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 54,
                          height: 54,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.red500,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Center(
                  child: IgnorePointer(
                    child: Icon(Icons.add, size: 28, color: AppColors.grey400),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      onTap: _resolvingCurrentLocation
                          ? null
                          : _useCurrentLocation,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _resolvingCurrentLocation
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: AppColors.emerald700,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.grey200, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected: ${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}',
                    style: AppTypography.bodySm,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmSelection,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(widget.confirmLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
