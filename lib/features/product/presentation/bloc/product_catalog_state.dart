part of 'product_catalog_bloc.dart';

sealed class ProductCatalogState {}

class ProductCatalogInitial extends ProductCatalogState {}

class ProductCatalogLoading extends ProductCatalogState {}

class ProductCatalogLoaded extends ProductCatalogState with EquatableMixin {
  final List<ProductCatalogEntity> products;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final int totalElements;
  // Filter fields
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
  final String sort;

  ProductCatalogLoaded({
    required this.products,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.totalElements = 0,
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
    this.sort = 'id,desc',
  });

  bool get hasActiveFilter =>
      categoryId != null ||
      brandId != null ||
      gender != null ||
      productSize != null ||
      color != null ||
      minPrice != null ||
      maxPrice != null;

  @override
  List<Object?> get props => [
        products,
        isLoadingMore,
        hasReachedMax,
        currentPage,
        totalElements,
        keyword,
        categoryId,
        categoryName,
        brandId,
        brandName,
        gender,
        productSize,
        color,
        minPrice,
        maxPrice,
        sort,
      ];

  ProductCatalogLoaded copyWith({
    List<ProductCatalogEntity>? products,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    int? totalElements,
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
    String? sort,
    // clearX flags — set field to null regardless of passed value
    bool clearKeyword = false,
    bool clearCategoryId = false,
    bool clearBrandId = false,
    bool clearGender = false,
    bool clearProductSize = false,
    bool clearColor = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductCatalogLoaded(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      categoryName:
          clearCategoryId ? null : (categoryName ?? this.categoryName),
      brandId: clearBrandId ? null : (brandId ?? this.brandId),
      brandName: clearBrandId ? null : (brandName ?? this.brandName),
      gender: clearGender ? null : (gender ?? this.gender),
      productSize: clearProductSize ? null : (productSize ?? this.productSize),
      color: clearColor ? null : (color ?? this.color),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      sort: sort ?? this.sort,
    );
  }
}

class ProductCatalogError extends ProductCatalogState with EquatableMixin {
  final String message;
  ProductCatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
