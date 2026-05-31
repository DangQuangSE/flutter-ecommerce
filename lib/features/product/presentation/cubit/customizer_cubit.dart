import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customization_entity.dart';
import 'customizer_state.dart';

class CustomizerCubit extends Cubit<CustomizerState> {
  final Map<String, CustomizationEntity> _customizations = {};

  CustomizerCubit() : super(const CustomizerInitial());

  void saveCustomization(String productId, CustomizationEntity customization) {
    _customizations[productId] = customization;
    emit(CustomizerActive(Map.from(_customizations)));
  }

  CustomizationEntity getCustomizationOrDefault(String productId) {
    if (_customizations.containsKey(productId)) {
      return _customizations[productId]!;
    }
    // Default initial customization matching designed AeroTech Tee
    return CustomizationEntity(
      productId: productId,
      customText: 'TEAM SPORT',
      textColor: 'Jet Black',
      colorHex: 0xFF1A1C1F,
      printMethod: 'In chuyển nhiệt',
      logoEnabled: true,
      textScale: 1.0,
    );
  }
}
