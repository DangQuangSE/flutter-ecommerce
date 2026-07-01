import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/storage/app_settings_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppSettingsStorage _settingsStorage;

  ThemeCubit(this._settingsStorage) : super(_settingsStorage.themeMode) {
    _updateColors(state);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _settingsStorage.setThemeMode(mode: mode);
    _updateColors(mode);
    emit(mode);
  }

  void _updateColors(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      AppColors.isDarkMode = true;
    } else if (mode == ThemeMode.light) {
      AppColors.isDarkMode = false;
    } else {
      AppColors.isDarkMode =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
    }
  }
}
