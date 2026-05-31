part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

final class ProductListRequested extends ProductEvent {
  const ProductListRequested();
}

final class ProductDetailRequested extends ProductEvent {
  final String productId;
  const ProductDetailRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}
