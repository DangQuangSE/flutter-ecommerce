import 'package:flutter_ecommerce/core/storage/local_storage.dart';

class AppSettingsStorage {
  static const String _notificationSoundEnabledKey =
      'notification_sound_enabled';

  final LocalStorage _localStorage;

  const AppSettingsStorage(this._localStorage);

  bool get isNotificationSoundEnabled =>
      _localStorage.getBool(_notificationSoundEnabledKey) ?? true;

  Future<void> setNotificationSoundEnabled({required bool value}) {
    return _localStorage.setBool(_notificationSoundEnabledKey, value: value);
  }
}
