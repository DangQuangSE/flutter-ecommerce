import 'dart:typed_data';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';

abstract interface class CustomDesignRemoteDataSource {
  Future<int> saveDesign({
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required String backMetadata,
    required Uint8List imageBytes,
    Uint8List? backImageBytes,
  });

  Future<PrintingConfigEntity> getPrintingConfigs();

  Future<
      ({
        String? designImageUrl,
        String? backDesignImageUrl,
        String designMetadata,
        String backDesignMetadata,
        String printingMaterialName,
        int? printingMaterialId,
        int numTextLines,
        int numImages,
        double totalPrintingPrice,
      })> getExistingDesign(int id, {DesignViewerRole role = DesignViewerRole.customer});
}
