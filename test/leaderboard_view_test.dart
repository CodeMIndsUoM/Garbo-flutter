import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/websocket_message_model.dart';

void main() {
  group('LeaderboardEntryDto Model Tests', () {
    test('LeaderboardEntryDto parses JSON correctly', () {
      final json = {
        'rank': 1,
        'userId': 456,
        'name': 'Collector Bob',
        'rewardPoints': 250.0,
        'role': 'COLLECTOR',
        'rankChangeFromPrevious': 2,
      };

      final entry = LeaderboardEntryDto.fromJson(json);

      expect(entry.rank, 1);
      expect(entry.userId, 456);
      expect(entry.name, 'Collector Bob');
      expect(entry.rewardPoints, 250.0);
      expect(entry.role, 'COLLECTOR');
      expect(entry.rankChangeFromPrevious, 2);
    });

    test('LeaderboardEntryDto toJson returns correct Map', () {
      final entry = LeaderboardEntryDto(
        rank: 2,
        userId: 789,
        name: 'Mentor Alice',
        rewardPoints: 300.0,
        role: 'FIELD_MENTOR',
        rankChangeFromPrevious: -1,
      );

      final json = entry.toJson();

      expect(json['rank'], 2);
      expect(json['userId'], 789);
      expect(json['name'], 'Mentor Alice');
      expect(json['rewardPoints'], 300.0);
      expect(json['role'], 'FIELD_MENTOR');
      expect(json['rankChangeFromPrevious'], -1);
    });
  });
}
