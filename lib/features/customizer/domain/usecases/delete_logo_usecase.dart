import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class DeleteLogoUseCase {
  final CustomDesignRepository _repository;

  const DeleteLogoUseCase(this._repository);

  Future<Result<void>> call(String url) => _repository.deleteLogo(url);
}
