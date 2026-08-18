import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';

void main() {
  group('ComplaintModel Tests', () {
    test('fromJson & toJson serialization', () {
      final jsonMap = {
        'id': 15,
        'assignedPersonnelId': 101,
        'citizenId': 202,
        'title': 'Bad smell from waste',
        'issueType': 'Bad smell from waste',
        'urgency': 'Medium',
        'wasteType': 'Organic',
        'council': 'Moratuwa',
        'createdAt': '2026-05-10T10:00:00.000Z',
        'description': 'Strong odor near the park',
        'imageUrl': 'https://example.com/photo.jpg',
        'location': '6.768943, 79.894123',
        'resolutionNotes': 'Verified on site',
        'status': 'IN_PROGRESS',
        'isConfirmedTrue': true,
        'fieldStaffNote': 'Cleaned up',
        'fieldStaffPhotoUrl': 'https://example.com/staff.jpg',
        'updatedAt': '2026-05-10T12:00:00.000Z',
      };

      final model = ComplaintModel.fromJson(jsonMap);

      expect(model.id, 15);
      expect(model.assignedPersonnelId, 101);
      expect(model.citizenId, 202);
      expect(model.title, 'Bad smell from waste');
      expect(model.issueType, 'Bad smell from waste');
      expect(model.urgency, 'Medium');
      expect(model.wasteType, 'Organic');
      expect(model.council, 'Moratuwa');
      expect(model.description, 'Strong odor near the park');
      expect(model.imageUrl, 'https://example.com/photo.jpg');
      expect(model.location, '6.768943, 79.894123');
      expect(model.status, 'IN_PROGRESS');
      expect(model.isConfirmedTrue, true);
      expect(model.fieldStaffNote, 'Cleaned up');
      expect(model.fieldStaffPhotoUrl, 'https://example.com/staff.jpg');

      final serialized = model.toJson();
      expect(serialized['id'], 15);
      expect(serialized['title'], 'Bad smell from waste');
      expect(serialized['status'], 'IN_PROGRESS');
    });

    test('computed presentation getters', () {
      final model = ComplaintModel(
        id: 42,
        title: 'Illegal Dumping Near Road',
        issueType: 'Illegal Dumping',
        location: '6.927100, 79.861200',
        urgency: 'HIGH',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(model.displayId, '#42');
      expect(model.displayTitle, 'Illegal Dumping Near Road');
      expect(model.displayIssueType, 'Illegal Dumping');
      expect(model.displayLocation, '6.927100, 79.861200');
      expect(model.displayUrgency, 'HIGH');
      expect(model.timeAgo, contains('ago'));
    });

    test('computed getters with fallback values when fields are null', () {
      final model = ComplaintModel(
        id: null,
        title: null,
        issueType: null,
        location: null,
        urgency: null,
        createdAt: null,
      );

      expect(model.displayId, '#--');
      expect(model.displayTitle, 'Special Task');
      expect(model.displayIssueType, 'General');
      expect(model.displayLocation, 'Location not specified');
      expect(model.displayUrgency, 'Normal');
      expect(model.timeAgo, 'Recently');
    });
  });
}
