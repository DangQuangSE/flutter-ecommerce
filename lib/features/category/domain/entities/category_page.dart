import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

/// A page of categories from the paginated list endpoint.
class CategoryPage extends Equatable {
  final List<CategoryEntity> items;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;

  const CategoryPage({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
  });

  @override
  List<Object?> get props => [items, page, totalPages, totalElements, isLast];
}
