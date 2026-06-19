import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';

sealed class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

final class ShopInitial extends ShopState {
  const ShopInitial();
}

final class ShopLoading extends ShopState {
  const ShopLoading();
}

final class ShopLoaded extends ShopState {
  final ShopEntity shop;

  const ShopLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

final class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}
