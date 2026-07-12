import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/data/datasources/custom_design_remote_datasource.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';

class CustomDesignRepositoryImpl implements CustomDesignRepository {
  final CustomDesignRemoteDataSource _dataSource;

  CustomDesignRepositoryImpl(this._dataSource);

  @override
  Future<Result<String>> uploadLogo(File file) async {
    try {
      final url = await _dataSource.uploadLogo(file);
      return Success(url);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> deleteLogo(String url) async {
    try {
      await _dataSource.deleteLogo(url);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<int>> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required String backMetadata,
    required Uint8List imageBytes,
    Uint8List? backImageBytes,
  }) async {
    try {
      final id = await _dataSource.saveDesign(
        materialId: materialId,
        numTextLines: numTextLines,
        numImages: numImages,
        metadata: metadata,
        backMetadata: backMetadata,
        imageBytes: imageBytes,
        backImageBytes: backImageBytes,
      );
      return Success(id);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ExistingDesignEntity>> getExistingDesign(int id) async {
    try {
      final result = await _dataSource.getExistingDesign(id);
      return Success(ExistingDesignEntity(
        designImageUrl: result.designImageUrl,
        backDesignImageUrl: result.backDesignImageUrl,
        designMetadata: result.designMetadata,
        backDesignMetadata: result.backDesignMetadata,
        printingMaterialName: result.printingMaterialName,
        printingMaterialId: result.printingMaterialId,
        numTextLines: result.numTextLines,
        numImages: result.numImages,
        totalPrintingPrice: result.totalPrintingPrice,
      ));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<ExistingDesignEntity>> getDesignForViewer(
    int id, {
    required DesignViewerRole role,
  }) async {
    try {
      final result = await _dataSource.getExistingDesign(id, role: role);
      return Success(ExistingDesignEntity(
        designImageUrl: result.designImageUrl,
        backDesignImageUrl: result.backDesignImageUrl,
        designMetadata: result.designMetadata,
        backDesignMetadata: result.backDesignMetadata,
        printingMaterialName: result.printingMaterialName,
        printingMaterialId: result.printingMaterialId,
        numTextLines: result.numTextLines,
        numImages: result.numImages,
        totalPrintingPrice: result.totalPrintingPrice,
      ));
    } on AppException catch (error) {
      return ResultFailure(NetworkFailure(error.message));
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
