import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/presentation/field_staff/suggestions/models/bin_suggestion_model.dart';

void main() {
  group('BinSuggestionModel Tests', () {
    test('fromJson deserializes properly', () {
      final json = {
        'id': 101,
        'mentorName': 'John Field Officer',
        'council': 'Colombo',
        'location': '6.9271, 79.8612',
        'latitude': 6.9271,
        'longitude': 79.8612,
        'category': 'Recyclables',
        'notes': 'High pedestrian traffic area needs a dedicated bin',
        'imageUrl': 'https://example.com/bin_photo.jpg',
        'status': 'APPROVED',
        'resolutionNotes': 'Approved by admin',
        'createdBinId': 55,
        'createdAt': '2026-06-01T08:30:00.000Z',
      };

      final model = BinSuggestionModel.fromJson(json);

      expect(model.id, 101);
      expect(model.mentorName, 'John Field Officer');
      expect(model.council, 'Colombo');
      expect(model.location, '6.9271, 79.8612');
      expect(model.latitude, 6.9271);
      expect(model.longitude, 79.8612);
      expect(model.category, 'Recyclables');
      expect(model.notes, 'High pedestrian traffic area needs a dedicated bin');
      expect(model.status, 'APPROVED');
      expect(model.displayStatus, 'Approved');
      expect(model.isPending, isFalse);
    });

    test('displayStatus and isPending getters for pending and rejected', () {
      final pending = BinSuggestionModel(id: 1, status: 'PENDING');
      expect(pending.displayStatus, 'Pending');
      expect(pending.isPending, isTrue);

      final rejected = BinSuggestionModel(id: 2, status: 'REJECTED');
      expect(rejected.displayStatus, 'Rejected');
      expect(rejected.isPending, isFalse);
    });
  });
}
