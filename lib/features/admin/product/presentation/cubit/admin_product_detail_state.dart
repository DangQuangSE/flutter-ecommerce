part of 'admin_product_detail_cubit.dart';

sealed class AdminProductDetailState {}

class AdminProductDetailInitial extends AdminProductDetailState {}

class AdminProductDetailLoading extends AdminProductDetailState {}

class AdminProductDetailSuccess extends AdminProductDetailState {
  final AdminProductDetailEntity product;
  AdminProductDetailSuccess(this.product);
}

class AdminProductDetailFailure extends AdminProductDetailState {
  final String message;
  AdminProductDetailFailure(this.message);
}
