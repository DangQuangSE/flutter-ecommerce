import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

sealed class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object?> get props => [];
}

class BrandInitial extends BrandState {
  const BrandInitial();
}

class BrandLoading extends BrandState {
  const BrandLoading();
}

class BrandLoaded extends BrandState {
  final List<BrandEntity> brands;
  final String? message;
  final bool isSubmitting;

  const BrandLoaded({
    required this.brands,
    this.message,
    this.isSubmitting = false,
  });

  BrandLoaded copyWith({
    List<BrandEntity>? brands,
    String? message,
    bool? isSubmitting,
  }) {
    return BrandLoaded(
      brands: brands ?? this.brands,
      message: message,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [brands, message, isSubmitting];
}

class BrandError extends BrandState {
  final String message;

  const BrandError(this.message);

  @override
  List<Object?> get props => [message];
}
