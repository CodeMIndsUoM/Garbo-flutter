import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/presentation/field_staff/bins/models/bin_model.dart';

void main() {
  group('BinModel.fromJson', () {
    test('parses a complete payload', () {
      final json = {
        'id': 'BIN-001',
        'location': 'Galle Road',
        'address': 'Colombo 03',
        'category': 'public',
        'status': 'full',
        'fillLevel': 95,
        'lastChecked': '2026-04-25T10:00:00Z',
      };

      final bin = BinModel.fromJson(json);

      expect(bin.id, 'BIN-001');
      expect(bin.location, 'Galle Road');
      expect(bin.address, 'Colombo 03');
      expect(bin.category, BinCategory.public);
      expect(bin.status, BinStatus.full);
      expect(bin.fillLevel, 95);
      expect(bin.lastChecked, isNotNull);
    });

    test('falls back to defaults for missing fields', () {
      final bin = BinModel.fromJson({});

      expect(bin.id, '');
      expect(bin.location, 'Unknown');
      expect(bin.address, 'Unknown');
      expect(bin.category, BinCategory.public);
      expect(bin.status, BinStatus.notChecked);
      expect(bin.fillLevel, isNull);
      expect(bin.lastChecked, isNull);
    });

    test('uses location as address fallback', () {
      final bin = BinModel.fromJson({
        'id': 'B1',
        'location': 'Park Lane',
      });

      expect(bin.address, 'Park Lane');
    });

    test('unknown status falls back to notChecked', () {
      final bin = BinModel.fromJson({'id': 'B1', 'status': 'NOT_A_STATUS'});

      expect(bin.status, BinStatus.notChecked);
    });

    test('unknown category falls back to public', () {
      final bin = BinModel.fromJson({'id': 'B1', 'category': 'spaceship'});

      expect(bin.category, BinCategory.public);
    });

    test('status parsing is case-insensitive', () {
      final bin = BinModel.fromJson({'id': 'B1', 'status': 'FULL'});

      expect(bin.status, BinStatus.full);
    });
  });

  group('BinStatus.label', () {
    test('returns human-readable labels for every status', () {
      expect(BinStatus.notChecked.label, 'Not Checked');
      expect(BinStatus.full.label, 'Full');
      expect(BinStatus.half.label, 'Half');
      expect(BinStatus.empty.label, 'Empty');
    });
  });

  group('BinCategory.label', () {
    test('returns human-readable labels for every category', () {
      expect(BinCategory.public.label, 'Public');
      expect(BinCategory.park.label, 'Park');
      expect(BinCategory.commercial.label, 'Commercial');
      expect(BinCategory.medical.label, 'Medical');
      expect(BinCategory.education.label, 'Education');
    });
  });

  group('BinModel.timeAgo', () {
    test('returns "Not checked today" when lastChecked is null', () {
      const bin = BinModel(
        id: 'B1',
        location: 'L',
        address: 'A',
        category: BinCategory.public,
      );

      expect(bin.timeAgo, 'Not checked today');
    });

    test('returns minutes for recent checks', () {
      final bin = BinModel(
        id: 'B1',
        location: 'L',
        address: 'A',
        category: BinCategory.public,
        lastChecked: DateTime.now().subtract(const Duration(minutes: 12)),
      );

      expect(bin.timeAgo, contains('mins ago'));
    });

    test('returns hours for sub-day checks', () {
      final bin = BinModel(
        id: 'B1',
        location: 'L',
        address: 'A',
        category: BinCategory.public,
        lastChecked: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(bin.timeAgo, contains('hour'));
      expect(bin.timeAgo, contains('ago'));
    });

    test('returns days for older checks', () {
      final bin = BinModel(
        id: 'B1',
        location: 'L',
        address: 'A',
        category: BinCategory.public,
        lastChecked: DateTime.now().subtract(const Duration(days: 4)),
      );

      expect(bin.timeAgo, contains('day'));
      expect(bin.timeAgo, contains('ago'));
    });
  });
}
