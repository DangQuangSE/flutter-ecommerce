import 'dart:io';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class UploadLogoUseCase {
  final CustomDesignRepository _repository;

  const UploadLogoUseCase(this._repository);

  Future<Result<String>> call(File file) => _repository.uploadLogo(file);
}
