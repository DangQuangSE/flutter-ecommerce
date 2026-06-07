part of 'admin_product_variant_cubit.dart';

sealed class AdminProductVariantState {}

class AdminProductVariantInitial extends AdminProductVariantState {}

class AdminProductVariantLoading extends AdminProductVariantState {}

class AdminProductVariantSuccess extends AdminProductVariantState {
  final List<ProductVariantEntity> variants;
  AdminProductVariantSuccess(this.variants);
}

class AdminProductVariantFailure extends AdminProductVariantState {
  final String message;
  AdminProductVariantFailure(this.message);
}
