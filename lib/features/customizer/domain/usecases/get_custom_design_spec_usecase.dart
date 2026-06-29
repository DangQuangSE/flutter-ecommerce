import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/custom_design_spec_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/repositories/custom_design_repository.dart';

class GetCustomDesignSpecUseCase {
  final CustomDesignRepository _repository;

  const GetCustomDesignSpecUseCase(this._repository);

  Future<Result<CustomDesignSpecEntity>> call(int id) async {
    final designResult = await _repository.getExistingDesign(id);
    if (designResult is ResultFailure<ExistingDesignEntity>) {
      return ResultFailure(designResult.failure);
    }

    final configResult = await _repository.getPrintingConfigs();
    if (configResult is ResultFailure<PrintingConfigEntity>) {
      return ResultFailure(configResult.failure);
    }

    if (designResult is! Success<ExistingDesignEntity> ||
        configResult is! Success<PrintingConfigEntity>) {
      return const ResultFailure(
        DomainFailure('Unable to load custom design details'),
      );
    }

    final design = designResult.data;
    final config = configResult.data;
    final material = _findMaterial(config, design);

    return Success(
      CustomDesignSpecEntity(
        materialName: design.printingMaterialName,
        numTextLines: design.numTextLines,
        numImages: design.numImages,
        totalPrintingPrice: design.totalPrintingPrice,
        materialBasePrice: material?.basePrice ?? 0.0,
        textUnitPrice: _unitPriceFor(config, 'TEXT'),
        imageUnitPrice: _unitPriceFor(config, 'IMAGE'),
      ),
    );
  }

  PrintingMaterialEntity? _findMaterial(
    PrintingConfigEntity config,
    ExistingDesignEntity design,
  ) {
    for (final material in config.materials) {
      if (design.printingMaterialId != null &&
          material.id == design.printingMaterialId) {
        return material;
      }
      if (material.name.toLowerCase() ==
          design.printingMaterialName.toLowerCase()) {
        return material;
      }
    }
    return null;
  }

  double _unitPriceFor(PrintingConfigEntity config, String type) {
    for (final priceConfig in config.priceConfigs) {
      if (priceConfig.type == type) return priceConfig.unitPrice;
    }
    return 0.0;
  }
}
