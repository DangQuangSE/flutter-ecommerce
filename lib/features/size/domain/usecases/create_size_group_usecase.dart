import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';

class CreateSizeGroupUseCase {
  final SizeGroupRepository _repository;

  const CreateSizeGroupUseCase(this._repository);

  Future<Result<SizeGroupEntity>> call(SizeGroupEntity entity) =>
      _repository.createSizeGroup(entity);
}
