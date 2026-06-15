import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/collection_offer_model.dart';

void main() {
  group('CollectionOfferModel.fromJson', () {
    test('parses a fully populated payload', () {
      final offer = CollectionOfferModel.fromJson({
        'id': 9,
        'requestId': 1,
        'collectorId': 7,
        'collectorName': 'Eco Collectors',
        'collectorCompany': 'Eco Pvt',
        'pricePerUnit': 150.0,
        'priceUnit': 'PER_KG',
        'proposedPickupAt': '2026-05-02T08:00:00Z',
        'messageToCitizen': 'Will arrive at 8 AM',
        'status': 'ACCEPTED',
        'completedAt': '2026-05-02T09:00:00Z',
        'createdAt': '2026-05-01T12:00:00Z',
        'citizenRating': 5,
        'citizenFeedback': 'Great service',
        'completionPhotoUrl': 'https://example.com/done.jpg',
      });

      expect(offer.id, 9);
      expect(offer.collectorCompany, 'Eco Pvt');
      expect(offer.pricePerUnit, 150.0);
      expect(offer.priceUnit, 'PER_KG');
      expect(offer.status, 'ACCEPTED');
      expect(offer.citizenRating, 5);
      expect(offer.completedAt, isNotNull);
    });

    test('applies defaults when optional fields are missing', () {
      final offer = CollectionOfferModel.fromJson({
        'id': 1,
        'requestId': 1,
        'collectorId': 1,
        'proposedPickupAt': '2026-05-02T08:00:00Z',
      });

      expect(offer.collectorName, 'Collector');
      expect(offer.collectorCompany, isNull);
      expect(offer.pricePerUnit, isNull);
      expect(offer.priceUnit, isNull);
      expect(offer.messageToCitizen, isNull);
      expect(offer.completedAt, isNull);
      expect(offer.createdAt, isNull);
      expect(offer.citizenRating, isNull);
    });
  });
}
