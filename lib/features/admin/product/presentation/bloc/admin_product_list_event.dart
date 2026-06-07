part of 'admin_product_list_bloc.dart';

sealed class AdminProductListEvent {}

class AdminProductListLoaded extends AdminProductListEvent {}

class AdminProductListRefreshed extends AdminProductListEvent {}

class AdminProductListLoadedMore extends AdminProductListEvent {}

class AdminProductListFiltered extends AdminProductListEvent {
  final String? keyword;
  final String? status;
  final int? categoryId;
  final int? brandId;
  final String? gender;
  final bool? isFeatured;

  AdminProductListFiltered({
    this.keyword,
    this.status,
    this.categoryId,
    this.brandId,
    this.gender,
    this.isFeatured,
  });
}

class AdminProductDeleted extends AdminProductListEvent {
  final int id;
  AdminProductDeleted(this.id);
}
