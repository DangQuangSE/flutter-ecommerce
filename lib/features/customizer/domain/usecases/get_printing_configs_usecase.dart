import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class GetPrintingConfigsUseCase {
  final CustomDesignRepository _repository;

  const GetPrintingConfigsUseCase(this._repository);

  Future<Result<PrintingConfigEntity>> call() {
    return _repository.getPrintingConfigs();
  }
}
