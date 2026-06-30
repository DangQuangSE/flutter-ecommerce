import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

sealed class ProductFilterOptionsState extends Equatable {
  const ProductFilterOptionsState();

  @override
  List<Object?> get props => [];
}

final class ProductFilterOptionsInitial extends ProductFilterOptionsState {
  const ProductFilterOptionsInitial();
}

final class ProductFilterOptionsLoading extends ProductFilterOptionsState {
  const ProductFilterOptionsLoading();
}

final class ProductFilterOptionsLoaded extends ProductFilterOptionsState {
  final List<CategoryTreeNode> categories;
  final List<BrandEntity> brands;
  final String? categoryError;
  final String? brandError;

  const ProductFilterOptionsLoaded({
    required this.categories,
    required this.brands,
    this.categoryError,
    this.brandError,
  });

  @override
  List<Object?> get props => [
        categories,
        brands,
        categoryError,
        brandError,
      ];
}
