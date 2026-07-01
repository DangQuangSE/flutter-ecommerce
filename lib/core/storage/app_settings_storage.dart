import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

class AppSettingsStorage {
  static const String _notificationSoundEnabledKey =
      'notification_sound_enabled';
  static const String _themeModeKey = 'theme_mode';

  final LocalStorage _localStorage;

  const AppSettingsStorage(this._localStorage);

  bool get isNotificationSoundEnabled =>
      _localStorage.getBool(_notificationSoundEnabledKey) ?? true;

  Future<void> setNotificationSoundEnabled({required bool value}) {
    return _localStorage.setBool(_notificationSoundEnabledKey, value: value);
  }

  ThemeMode get themeMode {
    final modeStr = _localStorage.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode({required ThemeMode mode}) {
    return _localStorage.setString(_themeModeKey, mode.name);
  }
}
