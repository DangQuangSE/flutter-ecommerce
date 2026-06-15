import 'dart:typed_data';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class SaveCustomDesignUseCase {
  final CustomDesignRepository _repository;

  const SaveCustomDesignUseCase(this._repository);

  Future<Result<int>> call({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
  }) {
    return _repository.saveDesign(
      materialId: materialId,
      numTextLines: numTextLines,
      numImages: numImages,
      metadata: metadata,
      imageBytes: imageBytes,
    );
  }
}
