import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/size/domain/repositories/size_group_repository.dart';

class DeleteSizeGroupUseCase {
  final SizeGroupRepository _repository;

  const DeleteSizeGroupUseCase(this._repository);

  Future<Result<void>> call(int id) => _repository.deleteSizeGroup(id);
}
