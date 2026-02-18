import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/header_reduced.dart';
import 'package:latlong2/latlong.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/presentation/collection_team/widgets/bottom_navigation.dart';

class CollectionTeamMap extends StatefulWidget {
  const CollectionTeamMap({super.key});

  @override
  State<CollectionTeamMap> createState() => CollectionTeamMapState();
}

class CollectionTeamMapState extends State<CollectionTeamMap> {
  final MapController mapController = MapController();
  
  final LatLng currentLocation = const LatLng(6.9271, 79.8612);
  
  final List<BinLocation> binLocations = [
    BinLocation(
      id: 'BIN-001',
      position: const LatLng(6.9271, 79.8612),
      status: BinStatus.urgent,
    ),
    BinLocation(
      id: 'BIN-002',
      position: const LatLng(6.9350, 79.8500),
      status: BinStatus.urgent,
    ),
    BinLocation(
      id: 'BIN-003',
      position: const LatLng(6.9180, 79.8700),
      status: BinStatus.pending,
    ),
    BinLocation(
      id: 'BIN-004',
      position: const LatLng(6.9400, 79.8650),
      status: BinStatus.pending,
    ),
    BinLocation(
      id: 'BIN-005',
      position: const LatLng(6.9150, 79.8550),
      status: BinStatus.pending,
    ),
    BinLocation(
      id: 'BIN-006',
      position: const LatLng(6.9320, 79.8720),
      status: BinStatus.pending,
    ),
    BinLocation(
      id: 'BIN-007',
      position: const LatLng(6.9200, 79.8600),
      status: BinStatus.pending,
    ),
    BinLocation(
      id: 'BIN-008',
      position: const LatLng(6.9380, 79.8580),
      status: BinStatus.pending,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Column(
        children: [
          HeaderReduced(),
          Expanded(
            child: Stack(
              children: [
                buildMapPlaceholder(),
                buildMapOverlay(),
              ],
            ),
          ),
          buildRouteStats(),
          buildStartNavigationButton(),
        ],
      ),
      bottomNavigationBar: const CollectionTeamBottomNav(currentIndex: 2),
    );
  }

  Widget buildMapPlaceholder() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.garbo.swms',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: binLocations.map((bin) {
            return Marker(
              point: bin.position,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => showBinDetails(bin),
                child: Container(
                  decoration: BoxDecoration(
                    color: getBinColor(bin.status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      bin.status == BinStatus.completed
                          ? Icons.check
                          : Icons.delete_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: currentLocation,
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.blue500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue500.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color getBinColor(BinStatus status) {
    switch (status) {
      case BinStatus.urgent:
        return AppColors.red500;
      case BinStatus.completed:
        return AppColors.green700;
      case BinStatus.issue:
        return AppColors.orange500;
      case BinStatus.pending:
        return AppColors.grey400;
    }
  }

  void showBinDetails(BinLocation bin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bin.id),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${bin.status.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text(
              'Location: ${bin.position.latitude.toStringAsFixed(4)}, ${bin.position.longitude.toStringAsFixed(4)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Collect'),
          ),
        ],
      ),
    );
  }

  Widget buildMapOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            mapController.move(currentLocation, 13.0);
          },
          child: const Icon(
            Icons.my_location,
            color: AppColors.green700,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget buildRouteStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildRouteStat('8', 'Bin stops'),
          Container(
            width: 1,
            height: 40,
            color: AppColors.grey200,
          ),
          buildRouteStat('14.7 km', 'Total Distance'),
          Container(
            width: 1,
            height: 40,
            color: AppColors.grey200,
          ),
          buildRouteStat('75 mins', 'Est. Time'),
        ],
      ),
    );
  }

  Widget buildRouteStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget buildStartNavigationButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Navigation starting...'),
                  backgroundColor: AppColors.green700,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.navigation, size: 20),
                SizedBox(width: 8),
                Text(
                  'Start Navigation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum BinStatus {
  urgent,
  completed,
  issue,
  pending,
}
class BinLocation {
  final String id;
  final LatLng position;
  final BinStatus status;

  BinLocation({
    required this.id,
    required this.position,
    required this.status,
  });
}