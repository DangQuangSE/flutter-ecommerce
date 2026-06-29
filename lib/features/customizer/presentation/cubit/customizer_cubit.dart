import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/customization_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/existing_design_entity.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_existing_design_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/get_printing_configs_usecase.dart';
import 'package:flutter_ecommerce/features/customizer/domain/usecases/save_custom_design_usecase.dart';
import 'customizer_state.dart';

class CustomizerCubit extends Cubit<CustomizerState> {
  final GetPrintingConfigsUseCase _getPrintingConfigs;
  final SaveCustomDesignUseCase _saveCustomDesign;
  final GetExistingDesignUseCase _getExistingDesign;
  final Map<String, CustomizationEntity> _customizations = {};

  CustomizerCubit({
    required GetPrintingConfigsUseCase getPrintingConfigs,
    required SaveCustomDesignUseCase saveCustomDesign,
    required GetExistingDesignUseCase getExistingDesign,
  })  : _getPrintingConfigs = getPrintingConfigs,
        _saveCustomDesign = saveCustomDesign,
        _getExistingDesign = getExistingDesign,
        super(const CustomizerInitial()) {
    _loadPersistedCustomizations();
  }

  Future<void> _loadPersistedCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('customizations');
    if (raw == null) return;
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final map = entry.value as Map<String, dynamic>;
        _customizations[entry.key] = _customizationFromJson(map);
      }
    } catch (_) {}
  }

  Future<void> loadPrintingConfigs({int? existingDesignId}) async {
    emit(const CustomizerLoading());

    ExistingDesignEntity? existingDesign;
    if (existingDesignId != null) {
      final existingResult = await _getExistingDesign(existingDesignId);
      switch (existingResult) {
        case Success(:final data):
          existingDesign = data;
        case ResultFailure():
          // non-fatal — editing continues with blank canvas
          break;
      }
    }

    final result = await _getPrintingConfigs();
    switch (result) {
      case Success(:final data):
        emit(CustomizerLoaded(
          printingConfigs: data,
          savedCustomizations: Map.from(_customizations),
          existingDesign: existingDesign,
        ));
      case ResultFailure(:final failure):
        emit(CustomizerError(failure.message));
    }
  }

  Future<void> saveCustomization({
    required String productId,
    required int materialId,
    required int numTextLines,
    required int numImages,
    required String metadata,
    required Uint8List imageBytes,
    required String activeText,
    required int activeColor,
    required double activeFontSize,
    required bool hasLogo,
    required String printMethod,
    required String layersJson,
  }) async {
    if (state
        case CustomizerLoaded(
          :final printingConfigs,
          :final savedCustomizations,
          :final existingDesign
        )) {
      emit(CustomizerSaving(
          printingConfigs: printingConfigs,
          savedCustomizations: savedCustomizations,
          existingDesign: existingDesign));
    } else {
      return;
    }

    final result = await _saveCustomDesign(
      materialId: materialId,
      numTextLines: numTextLines,
      numImages: numImages,
      metadata: metadata,
      imageBytes: imageBytes,
    );

    final loadedState = state;
    final configs =
        (loadedState is CustomizerSaving) ? loadedState.printingConfigs : null;
    final existingDesign =
        (loadedState is CustomizerSaving) ? loadedState.existingDesign : null;
    if (configs == null) return;

    switch (result) {
      case Success(:final data):
        final customDesignId = data;
        _customizations[productId] = CustomizationEntity(
          productId: productId,
          customText: activeText,
          textColor: 'Selected Color',
          colorHex: activeColor,
          printMethod: printMethod,
          logoEnabled: hasLogo,
          textScale: activeFontSize / 22.0,
          layersJson: layersJson,
          customDesignId: customDesignId,
        );
        await _persistCustomizations();
        emit(CustomizerLoaded(
          printingConfigs: configs,
          savedCustomizations: Map.from(_customizations),
          existingDesign: existingDesign,
        ));
      case ResultFailure():
        emit(CustomizerLoaded(
          printingConfigs: configs,
          savedCustomizations: Map.from(_customizations),
          existingDesign: existingDesign,
        ));
    }
  }

  CustomizationEntity getCustomizationOrDefault(String productId) {
    if (_customizations.containsKey(productId)) {
      return _customizations[productId]!;
    }
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

  Future<void> _persistCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> toSave = {};
    for (final e in _customizations.entries) {
      toSave[e.key] = _customizationToJson(e.value);
    }
    await prefs.setString('customizations', jsonEncode(toSave));
  }

  CustomizationEntity _customizationFromJson(Map<String, dynamic> json) {
    return CustomizationEntity(
      productId: json['productId'] as String? ?? '',
      customText: json['customText'] as String? ?? '',
      textColor: json['textColor'] as String? ?? '',
      colorHex: json['colorHex'] as int? ?? 0xFF1A1C1F,
      printMethod: json['printMethod'] as String? ?? 'In chuyển nhiệt',
      logoEnabled: json['logoEnabled'] as bool? ?? false,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      layersJson: json['layersJson'] as String? ?? '',
      customDesignId: json['customDesignId'] as int?,
    );
  }

  Map<String, dynamic> _customizationToJson(CustomizationEntity entity) {
    return {
      'productId': entity.productId,
      'customText': entity.customText,
      'textColor': entity.textColor,
      'colorHex': entity.colorHex,
      'printMethod': entity.printMethod,
      'logoEnabled': entity.logoEnabled,
      'textScale': entity.textScale,
      'layersJson': entity.layersJson,
      if (entity.customDesignId != null)
        'customDesignId': entity.customDesignId,
    };
  }
}
