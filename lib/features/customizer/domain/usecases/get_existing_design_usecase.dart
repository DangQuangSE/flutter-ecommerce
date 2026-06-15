import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class GetExistingDesignUseCase {
  final CustomDesignRepository _repository;

  const GetExistingDesignUseCase(this._repository);

  Future<Result<ExistingDesignEntity>> call(int id) {
    return _repository.getExistingDesign(id);
  }
}
