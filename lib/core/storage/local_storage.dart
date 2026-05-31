import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  const LocalStorage(this._prefs);

  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setBool(String key, {required bool value}) async =>
      _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> remove(String key) async => _prefs.remove(key);

  Future<void> clear() async => _prefs.clear();
}
