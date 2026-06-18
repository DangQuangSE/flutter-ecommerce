import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/data/datasources/size_group_remote_datasource.dart';
import 'package:flutter_ecommerce/features/size/data/models/size_group_model.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';

class SizeGroupRepositoryImpl implements SizeGroupRepository {
  final SizeGroupRemoteDatasource _datasource;

  const SizeGroupRepositoryImpl(this._datasource);

  @override
  Future<Result<List<SizeGroupEntity>>> getSizeGroups() async {
    try {
      final models = await _datasource.getSizeGroups();
      return Success(models);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<SizeGroupEntity>> createSizeGroup(
      SizeGroupEntity entity) async {
    try {
      final model = SizeGroupModel.fromEntity(entity);
      final result = await _datasource.createSizeGroup(model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<SizeGroupEntity>> updateSizeGroup(
      int id, SizeGroupEntity entity) async {
    try {
      final model = SizeGroupModel.fromEntity(entity);
      final result = await _datasource.updateSizeGroup(id, model);
      return Success(result);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSizeGroup(int id) async {
    try {
      await _datasource.deleteSizeGroup(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(DomainFailure(e.toString()));
    }
  }
}
