import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';

ProductCatalogEntity _makeEntity({
  double originalPrice = 200.0,
  double salePrice = 150.0,
}) =>
    ProductCatalogEntity(
      id: 1,
      name: 'Test',
      slug: 'test',
      basePrice: 100.0,
      originalPrice: originalPrice,
      salePrice: salePrice,
      categoryName: 'Cat',
      brandName: 'Brand',
      totalStock: 10,
      averageRating: 4.0,
      status: 'ACTIVE',
      availableSizes: const [],
      availableColors: const [],
    );

void main() {
  group('ProductCatalogEntity.hasDiscount', () {
    test('returns true when salePrice < originalPrice', () {
      final entity = _makeEntity(originalPrice: 300.0, salePrice: 225.0);
      expect(entity.hasDiscount, isTrue);
    });

    test('returns false when salePrice == originalPrice', () {
      final entity = _makeEntity(originalPrice: 200.0, salePrice: 200.0);
      expect(entity.hasDiscount, isFalse);
    });

    test('returns false when salePrice > originalPrice', () {
      // unusual but must not crash
      final entity = _makeEntity(originalPrice: 100.0, salePrice: 150.0);
      expect(entity.hasDiscount, isFalse);
    });

    test('returns true when salePrice is zero and originalPrice > 0', () {
      final entity = _makeEntity(originalPrice: 500.0, salePrice: 0.0);
      expect(entity.hasDiscount, isTrue);
    });

    test('returns false when both prices are zero', () {
      final entity = _makeEntity(originalPrice: 0.0, salePrice: 0.0);
      expect(entity.hasDiscount, isFalse);
    });
  });

  group('ProductCatalogEntity Equatable', () {
    test('two entities with same fields are equal', () {
      final a = _makeEntity(originalPrice: 200.0, salePrice: 150.0);
      final b = _makeEntity(originalPrice: 200.0, salePrice: 150.0);
      expect(a, equals(b));
    });

    test('two entities with different salePrice are not equal', () {
      final a = _makeEntity(salePrice: 100.0);
      final b = _makeEntity(salePrice: 200.0);
      expect(a, isNot(equals(b)));
    });
  });
}
