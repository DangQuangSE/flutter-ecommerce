import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/shop/data/models/shop_model.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';

void main() {
  group('ShopModel.fromJson', () {
    test('parses latitude/longitude when sent as JSON numbers', () {
      final json = {
        'id': 1,
        'name': 'Cửa hàng chính',
        'latitude': 10.7769,
        'longitude': 106.7009,
        'placeId': 'ChIJ123abc',
      };

      final model = ShopModel.fromJson(json);

      expect(model.latitude, 10.7769);
      expect(model.longitude, 106.7009);
      expect(model.placeId, 'ChIJ123abc');
    });

    test('parses latitude/longitude when sent as numeric strings', () {
      final json = {
        'id': 1,
        'name': 'Cửa hàng chính',
        'latitude': '10.7769',
        'longitude': '106.7009',
      };

      final model = ShopModel.fromJson(json);

      expect(model.latitude, 10.7769);
      expect(model.longitude, 106.7009);
    });

    test('parses whole-number latitude/longitude sent as JSON ints', () {
      final json = {
        'id': 1,
        'name': 'Cửa hàng chính',
        'latitude': 10,
        'longitude': 106,
      };

      final model = ShopModel.fromJson(json);

      expect(model.latitude, 10.0);
      expect(model.longitude, 106.0);
    });

    test('is null-safe when latitude/longitude/placeId keys are absent', () {
      final json = {
        'id': 1,
        'name': 'Cửa hàng chính',
      };

      final model = ShopModel.fromJson(json);

      expect(model.latitude, isNull);
      expect(model.longitude, isNull);
      expect(model.placeId, isNull);
    });

    test('is null-safe when latitude/longitude/placeId are explicit JSON null',
        () {
      final json = {
        'id': 1,
        'name': 'Cửa hàng chính',
        'latitude': null,
        'longitude': null,
        'placeId': null,
      };

      final model = ShopModel.fromJson(json);

      expect(model.latitude, isNull);
      expect(model.longitude, isNull);
      expect(model.placeId, isNull);
    });
  });

  group('ShopModel.toUpdateJson', () {
    test('includes latitude/longitude/placeId when non-null', () {
      const model = ShopModel(
        name: 'Cửa hàng chính',
        latitude: 10.7769,
        longitude: 106.7009,
        placeId: 'ChIJ123abc',
      );

      final json = model.toUpdateJson();

      expect(json['latitude'], 10.7769);
      expect(json['longitude'], 106.7009);
      expect(json['placeId'], 'ChIJ123abc');
    });

    test('omits latitude/longitude/placeId when null', () {
      const model = ShopModel(name: 'Cửa hàng chính');

      final json = model.toUpdateJson();

      expect(json.containsKey('latitude'), isFalse);
      expect(json.containsKey('longitude'), isFalse);
      expect(json.containsKey('placeId'), isFalse);
    });
  });

  group('ShopModel.fromEntity / toEntity', () {
    test('round-trips latitude, longitude, and placeId', () {
      const entity = ShopEntity(
        name: 'Cửa hàng chính',
        latitude: 21.0285,
        longitude: 105.8542,
        placeId: 'ChIJ999xyz',
      );

      final model = ShopModel.fromEntity(entity);
      final roundTripped = model.toEntity();

      expect(model.latitude, 21.0285);
      expect(model.longitude, 105.8542);
      expect(model.placeId, 'ChIJ999xyz');
      expect(roundTripped.latitude, 21.0285);
      expect(roundTripped.longitude, 105.8542);
      expect(roundTripped.placeId, 'ChIJ999xyz');
      expect(roundTripped, entity);
    });

    test('round-trips null latitude/longitude/placeId', () {
      const entity = ShopEntity(name: 'Cửa hàng chính');

      final roundTripped = ShopModel.fromEntity(entity).toEntity();

      expect(roundTripped.latitude, isNull);
      expect(roundTripped.longitude, isNull);
      expect(roundTripped.placeId, isNull);
      expect(roundTripped, entity);
    });
  });
}
