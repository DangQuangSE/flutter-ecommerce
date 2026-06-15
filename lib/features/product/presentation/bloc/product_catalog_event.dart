part of 'product_catalog_bloc.dart';

sealed class ProductCatalogEvent {}

class ProductCatalogFetch extends ProductCatalogEvent {}

class ProductCatalogRefreshed extends ProductCatalogEvent {}

class ProductCatalogLoadMore extends ProductCatalogEvent {}

class ProductCatalogFilterChanged extends ProductCatalogEvent {
  final String? keyword;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final String? gender;
  final String? productSize;
  final String? color;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;
  // When true: silent load (chip removals) — no full skeleton flash
  final bool silent;
  // clearX flags — when true, set that field to null even if a value is also passed
  final bool clearKeyword;
  final bool clearCategoryId;
  final bool clearBrandId;
  final bool clearGender;
  final bool clearProductSize;
  final bool clearColor;
  final bool clearMinPrice;
  final bool clearMaxPrice;
  final bool clearAll;

  ProductCatalogFilterChanged({
    this.keyword,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.gender,
    this.productSize,
    this.color,
    this.minPrice,
    this.maxPrice,
    this.sort,
    this.silent = false,
    this.clearKeyword = false,
    this.clearCategoryId = false,
    this.clearBrandId = false,
    this.clearGender = false,
    this.clearProductSize = false,
    this.clearColor = false,
    this.clearMinPrice = false,
    this.clearMaxPrice = false,
    this.clearAll = false,
  });
}

class ProductCatalogApplyFilter extends ProductCatalogEvent {
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final String? gender;
  final String? productSize;
  final String? color;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;

  ProductCatalogApplyFilter({
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.gender,
    this.productSize,
    this.color,
    this.minPrice,
    this.maxPrice,
    this.sort,
  });
}
