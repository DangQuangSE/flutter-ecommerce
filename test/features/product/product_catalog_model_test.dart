import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/product/data/models/product_catalog_model.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/core/models/paged_response.dart';

void main() {
  group('ProductCatalogModel.fromJson', () {
    test('happy path — all fields populated', () {
      final json = {
        'id': 42,
        'name': 'Áo thun nam',
        'slug': 'ao-thun-nam',
        'sku': 'SKU-001',
        'basePrice': 250000.0,
        'originalPrice': 300000.0,
        'salePrice': 225000.0,
        'imageUrl': 'https://example.com/image.jpg',
        'categoryName': 'Áo',
        'brandName': 'Nike',
        'totalStock': 50,
        'averageRating': 4.5,
        'status': 'ACTIVE',
        'gender': 'MALE',
        'availableSizes': ['S', 'M', 'L', 'XL'],
        'availableColors': ['red', 'blue'],
      };

      final model = ProductCatalogModel.fromJson(json);

      expect(model.id, 42);
      expect(model.name, 'Áo thun nam');
      expect(model.slug, 'ao-thun-nam');
      expect(model.sku, 'SKU-001');
      expect(model.basePrice, 250000.0);
      expect(model.originalPrice, 300000.0);
      expect(model.salePrice, 225000.0);
      expect(model.imageUrl, 'https://example.com/image.jpg');
      expect(model.categoryName, 'Áo');
      expect(model.brandName, 'Nike');
      expect(model.totalStock, 50);
      expect(model.averageRating, 4.5);
      expect(model.status, 'ACTIVE');
      expect(model.gender, 'MALE');
      expect(model.availableSizes, ['S', 'M', 'L', 'XL']);
      expect(model.availableColors, ['red', 'blue']);
    });

    test('null optional fields fall back to defaults', () {
      final json = {
        'id': 1,
        // name, slug, categoryName, brandName all null → ''
        'name': null,
        'slug': null,
        'sku': null,
        'basePrice': null,
        'originalPrice': null,
        'salePrice': null,
        'imageUrl': null,
        'categoryName': null,
        'brandName': null,
        'totalStock': null,
        'averageRating': null,
        'status': null,
        'gender': null,
        'availableSizes': null,
        'availableColors': null,
      };

      final model = ProductCatalogModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, '');
      expect(model.slug, '');
      expect(model.sku, isNull);
      expect(model.basePrice, 0.0);
      expect(model.originalPrice, 0.0);
      expect(model.salePrice, 0.0);
      expect(model.imageUrl, isNull);
      expect(model.categoryName, '');
      expect(model.brandName, '');
      expect(model.totalStock, 0);
      expect(model.averageRating, 0.0);
      expect(model.status, 'ACTIVE');
      expect(model.gender, isNull);
      expect(model.availableSizes, isEmpty);
      expect(model.availableColors, isEmpty);
    });

    test('int fields returned as int (not double) when JSON has numeric values', () {
      final json = {
        'id': 99,
        'totalStock': 10,
      };

      final model = ProductCatalogModel.fromJson(json);

      expect(model.id, isA<int>());
      expect(model.totalStock, isA<int>());
      expect(model.id, 99);
      expect(model.totalStock, 10);
    });

    test('price fields parsed correctly from integer JSON numbers', () {
      final json = {
        'id': 5,
        'basePrice': 100,
        'originalPrice': 200,
        'salePrice': 150,
      };

      final model = ProductCatalogModel.fromJson(json);

      expect(model.basePrice, isA<double>());
      expect(model.originalPrice, isA<double>());
      expect(model.salePrice, isA<double>());
      expect(model.basePrice, 100.0);
      expect(model.originalPrice, 200.0);
      expect(model.salePrice, 150.0);
    });

    test('availableSizes and availableColors mapped from dynamic list', () {
      final json = {
        'id': 7,
        'availableSizes': ['S', 'M'],
        'availableColors': ['white', 'black'],
      };

      final model = ProductCatalogModel.fromJson(json);

      expect(model.availableSizes, isA<List<String>>());
      expect(model.availableColors, isA<List<String>>());
      expect(model.availableSizes, ['S', 'M']);
      expect(model.availableColors, ['white', 'black']);
    });

    test('toEntity() maps all fields correctly', () {
      final json = {
        'id': 3,
        'name': 'Test Product',
        'slug': 'test-product',
        'sku': 'T-123',
        'basePrice': 100.0,
        'originalPrice': 200.0,
        'salePrice': 150.0,
        'imageUrl': 'https://img.com/p.jpg',
        'categoryName': 'Shoes',
        'brandName': 'Adidas',
        'totalStock': 20,
        'averageRating': 3.8,
        'status': 'ACTIVE',
        'gender': 'FEMALE',
        'availableSizes': ['38', '39'],
        'availableColors': ['pink'],
      };

      final entity = ProductCatalogModel.fromJson(json).toEntity();

      expect(entity, isA<ProductCatalogEntity>());
      expect(entity.id, 3);
      expect(entity.name, 'Test Product');
      expect(entity.slug, 'test-product');
      expect(entity.sku, 'T-123');
      expect(entity.basePrice, 100.0);
      expect(entity.originalPrice, 200.0);
      expect(entity.salePrice, 150.0);
      expect(entity.imageUrl, 'https://img.com/p.jpg');
      expect(entity.categoryName, 'Shoes');
      expect(entity.brandName, 'Adidas');
      expect(entity.totalStock, 20);
      expect(entity.averageRating, 3.8);
      expect(entity.status, 'ACTIVE');
      expect(entity.gender, 'FEMALE');
      expect(entity.availableSizes, ['38', '39']);
      expect(entity.availableColors, ['pink']);
    });
  });

  group('PagedResponse<ProductCatalogModel>.fromJson', () {
    test('parses totalPages/totalElements/number/size as int', () {
      final json = {
        'content': [
          {
            'id': 1,
            'name': 'P1',
            'slug': 'p1',
            'basePrice': 10.0,
            'originalPrice': 20.0,
            'salePrice': 10.0,
            'categoryName': 'Cat',
            'brandName': 'Brand',
            'totalStock': 5,
            'averageRating': 4.0,
            'status': 'ACTIVE',
            'availableSizes': [],
            'availableColors': [],
          }
        ],
        'totalPages': 3.0,
        // numbers that could come as doubles from JSON
        'totalElements': 25.0,
        'number': 0.0,
        'size': 12.0,
      };

      final paged = PagedResponse.fromJson(
        json,
        (e) => ProductCatalogModel.fromJson(e),
      );

      expect(paged.totalPages, isA<int>());
      expect(paged.totalElements, isA<int>());
      expect(paged.number, isA<int>());
      expect(paged.size, isA<int>());
      expect(paged.totalPages, 3);
      expect(paged.totalElements, 25);
      expect(paged.number, 0);
      expect(paged.size, 12);
      expect(paged.content, hasLength(1));
    });

    test('empty content with null pagination falls back to zeros', () {
      final json = <String, dynamic>{};

      final paged = PagedResponse.fromJson(
        json,
        (e) => ProductCatalogModel.fromJson(e),
      );

      expect(paged.content, isEmpty);
      expect(paged.totalPages, 0);
      expect(paged.totalElements, 0);
      expect(paged.number, 0);
      expect(paged.size, 0);
    });

    test('isLast is true on last page', () {
      final json = {
        'content': [],
        'totalPages': 2,
        'totalElements': 20,
        'number': 1,
        'size': 12,
      };

      final paged = PagedResponse.fromJson(
        json,
        (e) => ProductCatalogModel.fromJson(e),
      );

      expect(paged.isLast, isTrue);
    });

    test('isLast is false when not on last page', () {
      final json = {
        'content': [],
        'totalPages': 3,
        'totalElements': 30,
        'number': 0,
        'size': 12,
      };

      final paged = PagedResponse.fromJson(
        json,
        (e) => ProductCatalogModel.fromJson(e),
      );

      expect(paged.isLast, isFalse);
    });
  });
}
