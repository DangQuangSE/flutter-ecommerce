part of 'admin_product_list_bloc.dart';

sealed class AdminProductListState {}

class AdminProductListInitial extends AdminProductListState {}

class AdminProductListLoading extends AdminProductListState {}

class AdminProductListSuccess extends AdminProductListState {
  final List<AdminProductListEntity> products;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int currentPage;
  final int totalElements;
  final String? keyword;
  final String? status;
  final int? categoryId;
  final int? brandId;
  final String? gender;
  final bool? isFeatured;

  AdminProductListSuccess({
    required this.products,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.totalElements = 0,
    this.keyword,
    this.status,
    this.categoryId,
    this.brandId,
    this.gender,
    this.isFeatured,
  });

  AdminProductListSuccess copyWith({
    List<AdminProductListEntity>? products,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? currentPage,
    int? totalElements,
    String? keyword,
    String? status,
    int? categoryId,
    int? brandId,
    String? gender,
    bool? isFeatured,
  }) {
    return AdminProductListSuccess(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalElements: totalElements ?? this.totalElements,
      keyword: keyword ?? this.keyword,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      gender: gender ?? this.gender,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class AdminProductListFailure extends AdminProductListState {
  final String message;
  AdminProductListFailure(this.message);
}
