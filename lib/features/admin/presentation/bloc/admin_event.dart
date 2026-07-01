import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminStatsRequested extends AdminEvent {
  const AdminStatsRequested();
}

class AdminProductAdded extends AdminEvent {
  final ProductEntity product;
  const AdminProductAdded(this.product);

  @override
  List<Object?> get props => [product];
}

class AdminProductUpdated extends AdminEvent {
  final ProductEntity product;
  const AdminProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

class AdminProductDeleted extends AdminEvent {
  final String productId;
  const AdminProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}
