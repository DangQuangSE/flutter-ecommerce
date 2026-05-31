part of 'product_bloc.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

final class ProductDetailLoaded extends ProductState {
  final ProductEntity product;
  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

final class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
