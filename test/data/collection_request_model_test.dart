import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/collection_request_model.dart';

void main() {
  group('CollectionRequestModel.fromSummaryJson', () {
    test('parses a complete payload', () {
      final request = CollectionRequestModel.fromSummaryJson({
        'id': 42,
        'citizenId': 7,
        'citizenName': 'Sasindu',
        'wasteType': 'Plastic',
        'quantityLabel': '1-5 kg',
        'quantityKgEstimate': 3.5,
        'addressLine': '12 Galle Rd, Colombo 03',
        'latitude': 6.9,
        'longitude': 79.85,
        'preferredDate': '2026-05-01T00:00:00Z',
        'preferredSlot': 'MORNING',
        'contactPhone': '0771234567',
        'notes': 'Bell rings twice',
        'photoUrl': 'https://example.com/p.jpg',
        'status': 'OPEN',
        'acceptedOfferId': null,
        'offersCount': 0,
      });

      expect(request.id, 42);
      expect(request.citizenName, 'Sasindu');
      expect(request.wasteType, 'Plastic');
      expect(request.quantityKgEstimate, 3.5);
      expect(request.latitude, 6.9);
      expect(request.preferredSlot, 'MORNING');
      expect(request.status, 'OPEN');
      expect(request.offers, isEmpty);
    });

    test('handles missing optional fields gracefully', () {
      final request = CollectionRequestModel.fromSummaryJson({
        'id': 1,
        'preferredDate': '2026-05-01T00:00:00Z',
      });

      expect(request.id, 1);
      expect(request.citizenId, 0);
      expect(request.citizenName, '');
      expect(request.quantityKgEstimate, isNull);
      expect(request.notes, isNull);
      expect(request.photoUrl, isNull);
      expect(request.status, '');
      expect(request.offersCount, 0);
    });

    test('coerces numeric fields from int payloads', () {
      final request = CollectionRequestModel.fromSummaryJson({
        'id': 1,
        'latitude': 6,
        'longitude': 79,
        'preferredDate': '2026-05-01T00:00:00Z',
      });

      expect(request.latitude, 6.0);
      expect(request.longitude, 79.0);
    });
  });

  group('CollectionRequestModel.fromDetailJson', () {
    test('attaches offers and updates offersCount to match', () {
      final detail = CollectionRequestModel.fromDetailJson({
        'request': {
          'id': 1,
          'preferredDate': '2026-05-01T00:00:00Z',
        },
        'offers': [
          {
            'id': 100,
            'requestId': 1,
            'collectorId': 50,
            'collectorName': 'Test Collector',
            'pricePerUnit': 200.0,
            'priceUnit': 'PER_KG',
            'proposedPickupAt': '2026-05-02T08:00:00Z',
            'status': 'PENDING',
          },
        ],
      });

      expect(detail.offers, hasLength(1));
      expect(detail.offersCount, 1);
      expect(detail.offers.first.id, 100);
    });
  });
}
