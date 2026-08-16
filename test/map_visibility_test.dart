import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/route_model.dart';

void main() {
  group('RouteData and BinData Verification Tests', () {
    test('RouteData copyWith copies properties correctly', () {
      const original = RouteData(
        id: 'route-1',
        name: 'Colombo North Route',
        bins: 5,
        distance: 12.4,
        duration: 1800,
        progress: 40,
        totalBins: 5,
        status: RouteStatus.highPriority,
      );

      final copy = original.copyWith(progress: 60, status: RouteStatus.completed);

      expect(copy.id, 'route-1');
      expect(copy.name, 'Colombo North Route');
      expect(copy.progress, 60);
      expect(copy.status, RouteStatus.completed);
    });

    test('BinData constructor maps fields correctly', () {
      const bin = BinData(
        id: 'bin-100',
        name: 'Public Bin 100',
        address: 'Colombo Town Hall',
        distance: 1.2,
        duration: 200,
        fillStatus: BinFillStatus.full,
        isUrgent: true,
        nextDistance: 0.5,
        nextEta: 90,
      );

      expect(bin.id, 'bin-100');
      expect(bin.name, 'Public Bin 100');
      expect(bin.fillStatus, BinFillStatus.full);
      expect(bin.isUrgent, true);
      expect(bin.nextDistance, 0.5);
      expect(bin.nextEta, 90);
    });
  });
}
