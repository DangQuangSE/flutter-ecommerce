import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(const CategoryInitial());

  static const int pageSize = 20;

  String _search = '';
  int _page = 0;

  String get search => _search;

  /// Loads a page of categories. Pass [search] to filter; pass [page] to paginate.
  Future<void> load({String? search, int page = 0}) async {
    _search = search ?? _search;
    _page = page;
    emit(const CategoryLoading());
    final result = await _repository.getCategories(
      page: _page,
      size: pageSize,
      search: _search,
    );
    switch (result) {
      case Success(:final data):
        emit(CategoryLoaded(
          categories: data.items,
          page: data.page,
          totalPages: data.totalPages,
          totalElements: data.totalElements,
          isLast: data.isLast,
          search: _search,
        ));
      case ResultFailure(:final failure):
        emit(CategoryError(failure.message));
    }
  }

  Future<void> refresh() => load(search: _search, page: _page);

  /// `GET /api/categories/{slug}` — full detail. Returns null on failure.
  Future<CategoryEntity?> fetchDetail(String slug) async {
    final result = await _repository.getBySlug(slug);
    return switch (result) {
      Success(:final data) => data,
      ResultFailure() => null,
    };
  }

  /// `GET /api/categories/tree` — hierarchy. Returns empty list on failure.
  Future<List<CategoryTreeNode>> fetchTree() async {
    final result = await _repository.getTree();
    return switch (result) {
      Success(:final data) => data,
      ResultFailure() => const <CategoryTreeNode>[],
    };
  }

  Future<String?> uploadImage(File file) async {
    final result = await _repository.uploadCategoryImage(file);
    return switch (result) {
      Success(:final data) => data,
      ResultFailure() => null,
    };
  }

  /// Creates a category. Returns `null` on success, or an error message.
  Future<String?> create(CategoryEntity draft) =>
      _mutate(() => _repository.create(draft));

  Future<String?> update(int id, CategoryEntity draft) =>
      _mutate(() => _repository.update(id, draft));

  Future<String?> delete(int id) => _mutate(() => _repository.delete(id));

  Future<String?> toggleStatus(int id, {required bool isActive}) =>
      _mutate(() => _repository.updateStatus(id, isActive: isActive));

  /// Runs a mutating call, surfacing the busy flag, then reloads the page.
  Future<String?> _mutate(Future<Result<dynamic>> Function() action) async {
    final current = state;
    if (current is CategoryLoaded) {
      emit(current.copyWith(isMutating: true));
    }
    final result = await action();
    switch (result) {
      case Success():
        await refresh();
        return null;
      case ResultFailure(:final failure):
        if (current is CategoryLoaded) {
          emit(current.copyWith(isMutating: false));
        }
        return failure.message;
    }
  }
}
