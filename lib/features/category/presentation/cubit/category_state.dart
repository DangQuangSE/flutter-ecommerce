import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool isLast;
  final String search;

  /// True while a create/update/delete/toggle round-trip is in flight, so the
  /// UI can show a subtle busy indicator without dropping the current list.
  final bool isMutating;

  const CategoryLoaded({
    required this.categories,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.isLast,
    this.search = '',
    this.isMutating = false,
  });

  CategoryLoaded copyWith({
    List<CategoryEntity>? categories,
    int? page,
    int? totalPages,
    int? totalElements,
    bool? isLast,
    String? search,
    bool? isMutating,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      isLast: isLast ?? this.isLast,
      search: search ?? this.search,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props =>
      [categories, page, totalPages, totalElements, isLast, search, isMutating];
}

final class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
