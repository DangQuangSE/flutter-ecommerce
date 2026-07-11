import 'dart:typed_data';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';

abstract interface class CustomDesignRepository {
  Future<Result<int>> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required String backMetadata,
    required Uint8List imageBytes,
    Uint8List? backImageBytes,
  });

  Future<Result<PrintingConfigEntity>> getPrintingConfigs();

  Future<Result<ExistingDesignEntity>> getExistingDesign(int id);
  Future<Result<ExistingDesignEntity>> getDesignForViewer(
    int id, {
    required DesignViewerRole role,
  });
}
