import 'dart:typed_data';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';

abstract interface class CustomDesignRemoteDataSource {
  Future<int> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
  });

  Future<PrintingConfigEntity> getPrintingConfigs();

  Future<({String designMetadata, String printingMaterialName})>
      getExistingDesign(int id);
}
