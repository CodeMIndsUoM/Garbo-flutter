import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/route_model.dart';

void main() {
  group('Route Collection Status Enums Tests', () {
    test('BinCollectionStatus values are mapped correctly', () {
      expect(BinCollectionStatus.values.length, 4);
      expect(BinCollectionStatus.pending.index, 0);
      expect(BinCollectionStatus.collecting.index, 1);
      expect(BinCollectionStatus.collected.index, 2);
      expect(BinCollectionStatus.skipped.index, 3);
    });

    test('BinFillStatus has expected states', () {
      expect(BinFillStatus.values.contains(BinFillStatus.full), true);
      expect(BinFillStatus.values.contains(BinFillStatus.half), true);
    });
  });
}
