import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';

abstract interface class SizeGroupRepository {
  Future<Result<List<SizeGroupEntity>>> getSizeGroups();
  Future<Result<SizeGroupEntity>> createSizeGroup(SizeGroupEntity entity);
  Future<Result<SizeGroupEntity>> updateSizeGroup(
      int id, SizeGroupEntity entity);
  Future<Result<void>> deleteSizeGroup(int id);
}
