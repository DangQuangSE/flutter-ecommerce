import 'dart:typed_data';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/product/data/datasources/custom_design_remote_datasource.dart';
import 'package:flutter_ecommerce/features/product/domain/repositories/custom_design_repository.dart';

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
}
