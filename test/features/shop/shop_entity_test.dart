import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = ShopEntity(
    id: 1,
    name: 'Sport Pro',
    address: 'Old address',
    latitude: 10.0,
    longitude: 106.0,
    placeId: 'OLD_PLACE_ID',
    phone: '0909',
    openingHours: '08:00 - 21:00',
    description: 'desc',
    logoUrl: 'logo',
    coverUrl: 'cover',
  );

  group('ShopEntity.copyWith placeId sentinel', () {
    test('omitting placeId keeps the current value', () {
      final result = base.copyWith(latitude: 11.0, longitude: 107.0);
      expect(result.placeId, 'OLD_PLACE_ID');
      expect(result.latitude, 11.0);
      expect(result.longitude, 107.0);
    });

    test('placeId: () => null explicitly clears the stale placeId', () {
      // Simulates the admin dragging the pin: the picked place no longer
      // matches, so placeId must be cleared, not silently re-persisted.
      final result = base.copyWith(
        latitude: 12.0,
        longitude: 108.0,
        placeId: () => null,
      );
      expect(result.placeId, isNull);
    });

    test('placeId: () => value sets a new placeId', () {
      final result = base.copyWith(placeId: () => 'NEW_PLACE_ID');
      expect(result.placeId, 'NEW_PLACE_ID');
    });

    test('copyWith preserves untouched fields (no data loss on save)', () {
      final result = base.copyWith(
        latitude: 12.0,
        longitude: 108.0,
        placeId: () => null,
        address: 'New address',
      );
      expect(result.phone, '0909');
      expect(result.openingHours, '08:00 - 21:00');
      expect(result.description, 'desc');
      expect(result.logoUrl, 'logo');
      expect(result.coverUrl, 'cover');
      expect(result.name, 'Sport Pro');
    });
  });
}
