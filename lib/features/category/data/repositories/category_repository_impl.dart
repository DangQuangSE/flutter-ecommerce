import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/network/dio_error_mapper.dart';
import 'package:flutter_ecommerce/features/category/data/datasources/category_remote_datasource.dart';
import 'package:flutter_ecommerce/features/category/data/models/category_model.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_page.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  const CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<CategoryPage>> getCategories({
    int page = 0,
    int size = 20,
    String? search,
  }) {
    return _guard(() =>
        _remoteDataSource.getCategories(page: page, size: size, search: search));
  }

  @override
  Future<Result<CategoryEntity>> getBySlug(String slug) {
    return _guard(() => _remoteDataSource.getBySlug(slug));
  }

  @override
  Future<Result<List<CategoryTreeNode>>> getTree() {
    return _guard(() => _remoteDataSource.getTree());
  }

  @override
  Future<Result<CategoryEntity>> create(CategoryEntity category) {
    return _guard(
        () => _remoteDataSource.create(CategoryModel.fromEntity(category)));
  }

  @override
  Future<Result<CategoryEntity>> update(int id, CategoryEntity category) {
    return _guard(
        () => _remoteDataSource.update(id, CategoryModel.fromEntity(category)));
  }

  @override
  Future<Result<void>> delete(int id) {
    return _guard(() => _remoteDataSource.delete(id));
  }

  @override
  Future<Result<void>> updateStatus(int id, {required bool isActive}) {
    return _guard(() => _remoteDataSource.updateStatus(id, isActive: isActive));
  }

  /// Runs [action], mapping known exceptions to the corresponding [Failure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on UnauthorisedException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on ParseException catch (e) {
      return ResultFailure(ParseFailure(e.message));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } on DioException catch (e) {
      return ResultFailure(failureFromDioException(e));
    }
  }
}
