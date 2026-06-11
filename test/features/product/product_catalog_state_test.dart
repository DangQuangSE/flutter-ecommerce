import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';

ProductCatalogEntity _entity({int id = 1}) => ProductCatalogEntity(
      id: id,
      name: 'Product $id',
      slug: 'product-$id',
      basePrice: 100.0,
      originalPrice: 200.0,
      salePrice: 150.0,
      categoryName: 'Cat',
      brandName: 'Brand',
      totalStock: 5,
      averageRating: 4.0,
      status: 'ACTIVE',
      availableSizes: const [],
      availableColors: const [],
    );

ProductCatalogLoaded _loadedState({
  String? keyword,
  int? categoryId,
  String? categoryName,
  int? brandId,
  String? brandName,
  String? gender,
  String? productSize,
  String? color,
  double? minPrice,
  double? maxPrice,
}) =>
    ProductCatalogLoaded(
      products: [_entity()],
      keyword: keyword,
      categoryId: categoryId,
      categoryName: categoryName,
      brandId: brandId,
      brandName: brandName,
      gender: gender,
      productSize: productSize,
      color: color,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

void main() {
  group('ProductCatalogLoaded.copyWith — clearX flags', () {
    test('clearKeyword: true nullifies keyword even when keyword value is passed', () {
      final state = _loadedState(keyword: 'shoes');
      final next = state.copyWith(keyword: 'boots', clearKeyword: true);
      expect(next.keyword, isNull);
    });

    test('clearCategoryId: true nullifies categoryId and categoryName', () {
      final state = _loadedState(categoryId: 5, categoryName: 'Shirts');
      final next = state.copyWith(
        categoryId: 10,
        categoryName: 'Pants',
        clearCategoryId: true,
      );
      expect(next.categoryId, isNull);
      expect(next.categoryName, isNull);
    });

    test('clearBrandId: true nullifies brandId and brandName', () {
      final state = _loadedState(brandId: 3, brandName: 'Nike');
      final next = state.copyWith(
        brandId: 7,
        brandName: 'Adidas',
        clearBrandId: true,
      );
      expect(next.brandId, isNull);
      expect(next.brandName, isNull);
    });

    test('clearGender: true nullifies gender', () {
      final state = _loadedState(gender: 'MALE');
      final next = state.copyWith(gender: 'FEMALE', clearGender: true);
      expect(next.gender, isNull);
    });

    test('clearProductSize: true nullifies productSize', () {
      final state = _loadedState(productSize: 'XL');
      final next = state.copyWith(productSize: 'S', clearProductSize: true);
      expect(next.productSize, isNull);
    });

    test('clearColor: true nullifies color', () {
      final state = _loadedState(color: 'red');
      final next = state.copyWith(color: 'blue', clearColor: true);
      expect(next.color, isNull);
    });

    test('clearMinPrice: true nullifies minPrice', () {
      final state = _loadedState(minPrice: 100.0);
      final next = state.copyWith(minPrice: 200.0, clearMinPrice: true);
      expect(next.minPrice, isNull);
    });

    test('clearMaxPrice: true nullifies maxPrice', () {
      final state = _loadedState(maxPrice: 500.0);
      final next = state.copyWith(maxPrice: 1000.0, clearMaxPrice: true);
      expect(next.maxPrice, isNull);
    });

    test('no clear flags: copyWith preserves existing values when null args given', () {
      final state = _loadedState(
        keyword: 'shirt',
        categoryId: 2,
        categoryName: 'Tops',
      );
      final next = state.copyWith(isLoadingMore: true);
      expect(next.keyword, 'shirt');
      expect(next.categoryId, 2);
      expect(next.categoryName, 'Tops');
      expect(next.isLoadingMore, isTrue);
    });

    test('copyWith updates products list', () {
      final state = _loadedState();
      final newProducts = [_entity(id: 2), _entity(id: 3)];
      final next = state.copyWith(products: newProducts);
      expect(next.products, hasLength(2));
      expect(next.products[0].id, 2);
      expect(next.products[1].id, 3);
    });

    test('all clear flags false: non-null values are updated', () {
      final state = _loadedState(keyword: 'old', categoryId: 1);
      final next = state.copyWith(keyword: 'new', categoryId: 2);
      expect(next.keyword, 'new');
      expect(next.categoryId, 2);
    });
  });

  group('ProductCatalogLoaded.hasActiveFilter', () {
    test('false when all filter fields are null', () {
      final state = ProductCatalogLoaded(products: const []);
      expect(state.hasActiveFilter, isFalse);
    });

    test('false when only keyword is set (search bar shows it visually)', () {
      final state = _loadedState(keyword: 'jeans');
      expect(state.hasActiveFilter, isFalse);
    });

    test('true when categoryId is set', () {
      final state = _loadedState(categoryId: 1);
      expect(state.hasActiveFilter, isTrue);
    });

    test('true when brandId is set', () {
      final state = _loadedState(brandId: 2);
      expect(state.hasActiveFilter, isTrue);
    });

    test('true when gender is set', () {
      final state = _loadedState(gender: 'FEMALE');
      expect(state.hasActiveFilter, isTrue);
    });

    test('true when productSize is set', () {
      final state = _loadedState(productSize: 'M');
      expect(state.hasActiveFilter, isTrue);
    });

    test('true when color is set', () {
      final state = _loadedState(color: 'black');
      expect(state.hasActiveFilter, isTrue);
    });

    test('true when minPrice is set', () {
      final state = _loadedState(minPrice: 50.0);
      expect(state.hasActiveFilter, isTrue);
    });

    test('true when maxPrice is set', () {
      final state = _loadedState(maxPrice: 500.0);
      expect(state.hasActiveFilter, isTrue);
    });

    test('brandName alone does NOT activate filter (not in hasActiveFilter)', () {
      // brandName is denormalized, not checked in hasActiveFilter
      final state = _loadedState(brandName: 'Nike');
      expect(state.hasActiveFilter, isFalse);
    });

    test('categoryName alone does NOT activate filter', () {
      final state = _loadedState(categoryName: 'Shoes');
      expect(state.hasActiveFilter, isFalse);
    });

    test('after clearKeyword the filter becomes inactive if keyword was the only filter', () {
      final state = _loadedState(keyword: 'boots');
      final next = state.copyWith(clearKeyword: true);
      expect(next.hasActiveFilter, isFalse);
    });
  });

  group('ProductCatalogLoaded.hasReachedMax guard', () {
    test('copyWith preserves hasReachedMax', () {
      final state = ProductCatalogLoaded(
        products: const [],
        hasReachedMax: true,
      );
      final next = state.copyWith(isLoadingMore: false);
      expect(next.hasReachedMax, isTrue);
    });
  });

  group('ProductCatalogLoaded default values', () {
    test('default sort is id,desc', () {
      final state = ProductCatalogLoaded(products: const []);
      expect(state.sort, 'id,desc');
    });

    test('default isLoadingMore is false', () {
      final state = ProductCatalogLoaded(products: const []);
      expect(state.isLoadingMore, isFalse);
    });

    test('default hasReachedMax is false', () {
      final state = ProductCatalogLoaded(products: const []);
      expect(state.hasReachedMax, isFalse);
    });

    test('default currentPage is 0', () {
      final state = ProductCatalogLoaded(products: const []);
      expect(state.currentPage, 0);
    });

    test('default totalElements is 0', () {
      final state = ProductCatalogLoaded(products: const []);
      expect(state.totalElements, 0);
    });
  });
}
