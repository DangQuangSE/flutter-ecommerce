import 'dart:typed_data';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';

class CustomDesignRepositoryImpl implements CustomDesignRepository {
  final CustomDesignRemoteDataSource _dataSource;

  CustomDesignRepositoryImpl(this._dataSource);

  @override
  Future<Result<int>> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
  }) async {
    try {
      final id = await _dataSource.saveDesign(
        materialId: materialId,
        numTextLines: numTextLines,
        numImages: numImages,
        metadata: metadata,
        imageBytes: imageBytes,
      );
      return Success(id);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<PrintingConfigEntity>> getPrintingConfigs() async {
    try {
      final configs = await _dataSource.getPrintingConfigs();
      return Success(configs);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
