import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/customization_entity.dart';
import 'customizer_state.dart';

class CustomizerCubit extends Cubit<CustomizerState> {
  final Map<String, CustomizationEntity> _customizations = {};

  CustomizerCubit() : super(const CustomizerInitial()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('customizations');
    if (raw == null) return;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final map = entry.value as Map<String, dynamic>;
        _customizations[entry.key] = CustomizationEntity(
          productId: map['productId'] as String? ?? entry.key,
          customText: map['customText'] as String? ?? '',
          textColor: map['textColor'] as String? ?? '',
          colorHex: map['colorHex'] as int? ?? 0xFF1A1C1F,
          printMethod: map['printMethod'] as String? ?? 'In chuyển nhiệt',
          logoEnabled: map['logoEnabled'] as bool? ?? false,
          textScale: (map['textScale'] as num?)?.toDouble() ?? 1.0,
          layersJson: map['layersJson'] as String? ?? '',
          customDesignId: map['customDesignId'] as int?,
        );
      }
      if (_customizations.isNotEmpty) {
        emit(CustomizerActive(Map.from(_customizations)));
      }
    } catch (_) {}
  }

  Future<void> saveCustomization(String productId, CustomizationEntity customization) async {
    _customizations[productId] = customization;
    emit(CustomizerActive(Map.from(_customizations)));
    await _persist();
  }

  Future<void> updateCustomDesignId(String productId, int customDesignId) async {
    final existing = _customizations[productId];
    if (existing != null) {
      _customizations[productId] = existing.copyWith(customDesignId: customDesignId);
      emit(CustomizerActive(Map.from(_customizations)));
      await _persist();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> toSave = {};
    for (final e in _customizations.entries) {
      toSave[e.key] = {
        'productId': e.value.productId,
        'customText': e.value.customText,
        'textColor': e.value.textColor,
        'colorHex': e.value.colorHex,
        'printMethod': e.value.printMethod,
        'logoEnabled': e.value.logoEnabled,
        'textScale': e.value.textScale,
        'layersJson': e.value.layersJson,
        if (e.value.customDesignId != null) 'customDesignId': e.value.customDesignId,
      };
    }
    await prefs.setString('customizations', jsonEncode(toSave));
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
}
