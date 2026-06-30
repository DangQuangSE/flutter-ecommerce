import 'package:flutter_ecommerce/core/constants/app_strings.dart';

enum ProductListSortOption {
  none,
  priceAscending,
  priceDescending;

  String get label {
    return switch (this) {
      ProductListSortOption.none => AppStrings.productListSortNone,
      ProductListSortOption.priceAscending => AppStrings.productSortPriceAsc,
      ProductListSortOption.priceDescending => AppStrings.productSortPriceDesc,
    };
  }

  String get sheetLabel {
    return switch (this) {
      ProductListSortOption.none => AppStrings.productListSortNone,
      ProductListSortOption.priceAscending =>
        AppStrings.productListSortPriceLowToHigh,
      ProductListSortOption.priceDescending =>
        AppStrings.productListSortPriceHighToLow,
    };
  }
}

class ProductListCategoryOption {
  final String label;
  final String? categoryId;

  const ProductListCategoryOption({
    required this.label,
    this.categoryId,
  });

  static const all = ProductListCategoryOption(
    label: AppStrings.productFilterAll,
  );

  static const defaults = [
    all,
    ProductListCategoryOption(
      label: AppStrings.productListCategoryRunning,
      categoryId: 'cat-running',
    ),
    ProductListCategoryOption(label: AppStrings.productListCategoryMen),
    ProductListCategoryOption(label: AppStrings.productListCategorySize42),
    ProductListCategoryOption(
      label: AppStrings.productListCategoryClothing,
      categoryId: 'cat-clothing',
    ),
  ];
}
