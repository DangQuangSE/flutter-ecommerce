import 'dart:io';

import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_page.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

abstract interface class CategoryRepository {
  Future<Result<CategoryPage>> getCategories({
    int page,
    int size,
    String? search,
  });

  /// `GET /api/categories/{slug}` — full detail of a single category.
  Future<Result<CategoryEntity>> getBySlug(String slug);

  /// `GET /api/categories/tree` — hierarchical category tree.
  Future<Result<List<CategoryTreeNode>>> getTree();

  Future<Result<CategoryEntity>> create(CategoryEntity category);

  Future<Result<CategoryEntity>> update(int id, CategoryEntity category);

  Future<Result<void>> delete(int id);

  Future<Result<void>> updateStatus(int id, {required bool isActive});

  Future<Result<String>> uploadCategoryImage(File file);
}
