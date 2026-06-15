import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';

class UpdateSizeGroupUseCase {
  final SizeGroupRepository _repository;

  const UpdateSizeGroupUseCase(this._repository);

  Future<Result<SizeGroupEntity>> call(int id, SizeGroupEntity entity) =>
      _repository.updateSizeGroup(id, entity);
}
