import 'package:flutter_ecommerce/features/customizer/domain/entities/customization_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/printing_config_entity.dart';

sealed class CustomizerState {
  const CustomizerState();
}

final class CustomizerInitial extends CustomizerState {
  const CustomizerInitial();
}

final class CustomizerLoading extends CustomizerState {
  const CustomizerLoading();
}

final class CustomizerError extends CustomizerState {
  final String message;

  const CustomizerError(this.message);
}

final class CustomizerLoaded extends CustomizerState {
  final PrintingConfigEntity printingConfigs;
  final Map<String, CustomizationEntity> savedCustomizations;
  final ExistingDesignEntity? existingDesign;

  const CustomizerLoaded({
    required this.printingConfigs,
    this.savedCustomizations = const {},
    this.existingDesign,
  });
}

final class CustomizerSaving extends CustomizerState {
  final PrintingConfigEntity printingConfigs;
  final Map<String, CustomizationEntity> savedCustomizations;
  final ExistingDesignEntity? existingDesign;

  const CustomizerSaving({
    required this.printingConfigs,
    this.savedCustomizations = const {},
    this.existingDesign,
  });
}
