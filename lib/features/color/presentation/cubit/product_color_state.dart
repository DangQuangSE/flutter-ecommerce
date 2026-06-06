import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';

sealed class ProductColorState extends Equatable {
  const ProductColorState();

  @override
  List<Object?> get props => [];
}

class ProductColorInitial extends ProductColorState {
  const ProductColorInitial();
}

class ProductColorLoading extends ProductColorState {
  const ProductColorLoading();
}

class ProductColorLoaded extends ProductColorState {
  final List<ProductColorEntity> colors;
  final String? message;
  final bool isSubmitting;

  const ProductColorLoaded({
    required this.colors,
    this.message,
    this.isSubmitting = false,
  });

  ProductColorLoaded copyWith({
    List<ProductColorEntity>? colors,
    String? message,
    bool? isSubmitting,
  }) {
    return ProductColorLoaded(
      colors: colors ?? this.colors,
      message: message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [colors, message, isSubmitting];
}

class ProductColorError extends ProductColorState {
  final String message;

  const ProductColorError(this.message);

  @override
  List<Object?> get props => [message];
}
