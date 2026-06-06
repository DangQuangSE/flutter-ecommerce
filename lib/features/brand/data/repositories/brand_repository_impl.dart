import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/data/datasources/brand_remote_datasource.dart';
import 'package:flutter_ecommerce/features/brand/data/models/brand_model.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource _remoteDataSource;

  const BrandRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<BrandEntity>>> getBrands({
    int page = 0,
    int size = 100,
    String? search,
  }) async {
    try {
      final models = await _remoteDataSource.getBrands(
        page: page,
        size: size,
        search: search,
      );
      return Success(models);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<BrandEntity>> createBrand(BrandEntity brand) async {
    try {
      final model = BrandModel.fromEntity(brand);
      final result = await _remoteDataSource.createBrand(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<BrandEntity>> updateBrand(int id, BrandEntity brand) async {
    try {
      final model = BrandModel.fromEntity(brand);
      final result = await _remoteDataSource.updateBrand(id, model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBrand(int id) async {
    try {
      await _remoteDataSource.deleteBrand(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateBrandStatus(int id, bool isActive) async {
    try {
      await _remoteDataSource.updateBrandStatus(id, isActive);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
