import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/gamification_task_model.dart';

void main() {
  group('UserTaskProgress Model Tests', () {
    test('UserTaskProgress parses and calculates progressPercentage correctly', () {
      final json = {
        'userId': 100,
        'taskId': 5,
        'taskCode': 'TASK_05',
        'taskTitle': 'Collect 10 Bins',
        'availablePoints': 100.0,
        'currentProgress': 4.0,
        'targetProgress': 10.0,
        'isCompleted': false,
        'isNew': true,
        'pointsEarned': 0.0,
      };

      final progress = UserTaskProgress.fromJson(json);

      expect(progress.userId, 100);
      expect(progress.progressPercentage, 40.0);
      expect(progress.pointsStatusLabel, 'Reward: 100 pts');
    });

    test('UserTaskProgress returns correct labels when completed', () {
      final json = {
        'userId': 100,
        'taskId': 5,
        'taskCode': 'TASK_05',
        'taskTitle': 'Collect 10 Bins',
        'availablePoints': 100.0,
        'currentProgress': 10.0,
        'targetProgress': 10.0,
        'completed': true, // Testing completed mapping alias
        'isNew': false,
        'pointsEarned': 100.0,
      };

      final progress = UserTaskProgress.fromJson(json);

      expect(progress.isCompleted, true);
      expect(progress.progressPercentage, 100.0);
      expect(progress.pointsStatusLabel, '100 pts earned');
    });
  });
}
