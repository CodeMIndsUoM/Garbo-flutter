import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/presentation/providers/auth_provider.dart';

void main() {
  group('Duty Status Formatting and Parsing Tests', () {
    test('AppUser.fromJson parses onDuty correctly', () {
      final json = {
        'empId': 123,
        'empName': 'Collector Bob',
        'email': 'bob@garbo.local',
        'role': 'BIN_COLLECTOR',
        'onDuty': true,
        'rewardPoints': 100.5,
        'createdAt': '2026-08-16T00:00:00Z',
        'lastLoginAt': '2026-08-16T00:00:00Z'
      };

      final user = AppUser.fromJson(json);

      expect(user.empId, 123);
      expect(user.empName, 'Collector Bob');
      expect(user.onDuty, true);
      expect(user.rewardPoints, 100.5);
    });

    test('AppUser.fromJson defaults onDuty to false if missing', () {
      final json = {
        'empId': 124,
        'empName': 'Collector Alice',
        'email': 'alice@garbo.local',
        'role': 'BIN_COLLECTOR',
        'rewardPoints': 0
      };

      final user = AppUser.fromJson(json);

      expect(user.empId, 124);
      expect(user.onDuty, false);
    });
  });
}
