import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

ProductEntity _makeProduct({int stockQuantity = 10}) => ProductEntity(
      id: 'p1',
      name: 'Test Product',
      description: 'A product',
      price: 99.0,
      imageUrl: 'https://example.com/img.jpg',
      categoryId: 'cat1',
      stockQuantity: stockQuantity,
    );

void main() {
  group('ProductEntity.isInStock', () {
    test('returns true when stockQuantity > 0', () {
      expect(_makeProduct(stockQuantity: 5).isInStock, isTrue);
    });

    test('returns false when stockQuantity is 0', () {
      expect(_makeProduct(stockQuantity: 0).isInStock, isFalse);
    });

    test('returns true when stockQuantity is 1', () {
      expect(_makeProduct(stockQuantity: 1).isInStock, isTrue);
    });
  });

  group('ProductEntity Equatable', () {
    test('two identical entities are equal', () {
      final a = _makeProduct();
      final b = _makeProduct();
      expect(a, equals(b));
    });

    test('entities with different stockQuantity are not equal', () {
      final a = _makeProduct(stockQuantity: 1);
      final b = _makeProduct(stockQuantity: 2);
      expect(a, isNot(equals(b)));
    });
  });

  group('ProductVariantEntity', () {
    test('constructs and exposes props', () {
      const variant = ProductVariantEntity(
        id: 1,
        sku: 'SKU-001',
        size: 'M',
        colorId: 2,
        colorName: 'Red',
        colorHex: '#FF0000',
        originalPrice: 100.0,
        salePrice: 80.0,
        stockQuantity: 5,
        status: ProductStatus.active,
      );
      expect(variant.id, 1);
      expect(variant.sku, 'SKU-001');
      expect(variant.props, isNotEmpty);
    });

    test('null salePrice is allowed', () {
      const variant = ProductVariantEntity(
        id: 2,
        sku: 'SKU-002',
        size: 'L',
        colorId: 3,
        colorName: 'Blue',
        colorHex: '#0000FF',
        originalPrice: 120.0,
        stockQuantity: 10,
        status: ProductStatus.inactive,
      );
      expect(variant.salePrice, isNull);
    });
  });

  group('ProductStatus', () {
    test('toJson returns uppercase name', () {
      expect(ProductStatus.active.toJson(), 'ACTIVE');
      expect(ProductStatus.inactive.toJson(), 'INACTIVE');
      expect(ProductStatus.deleted.toJson(), 'DELETED');
    });

    test('fromJson parses lowercase value', () {
      expect(ProductStatus.fromJson('active'), ProductStatus.active);
      expect(ProductStatus.fromJson('inactive'), ProductStatus.inactive);
      expect(ProductStatus.fromJson('deleted'), ProductStatus.deleted);
    });

    test('fromJson falls back to active for unknown value', () {
      expect(ProductStatus.fromJson('unknown'), ProductStatus.active);
    });
  });
}
