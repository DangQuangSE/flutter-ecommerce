import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';

class GetSizeGroupsUseCase {
  final SizeGroupRepository _repository;

  const GetSizeGroupsUseCase(this._repository);

  Future<Result<List<SizeGroupEntity>>> call() => _repository.getSizeGroups();
}
