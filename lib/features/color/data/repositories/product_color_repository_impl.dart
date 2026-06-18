import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/color/data/datasources/product_color_remote_datasource.dart';
import 'package:flutter_ecommerce/features/color/data/models/product_color_model.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';
import 'package:flutter_ecommerce/features/color/domain/repositories/product_color_repository.dart';

class ProductColorRepositoryImpl implements ProductColorRepository {
  final ProductColorRemoteDataSource _remoteDataSource;

  const ProductColorRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<ProductColorEntity>>> getColors() async {
    try {
      final models = await _remoteDataSource.getColors();
      return Success(models);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProductColorEntity>> createColor(
      ProductColorEntity color) async {
    try {
      final model = ProductColorModel.fromEntity(color);
      final result = await _remoteDataSource.createColor(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<ProductColorEntity>> updateColor(
      int id, ProductColorEntity color) async {
    try {
      final model = ProductColorModel.fromEntity(color);
      final result = await _remoteDataSource.updateColor(id, model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteColor(int id) async {
    try {
      await _remoteDataSource.deleteColor(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
