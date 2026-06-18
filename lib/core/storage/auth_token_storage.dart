import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

class AuthTokenStorage {
  final LocalStorage _localStorage;

  const AuthTokenStorage(this._localStorage);

  Future<void> saveAccessToken(String token) =>
      _localStorage.setString(AppConstants.tokenKey, token);

  String? getAccessToken() => _localStorage.getString(AppConstants.tokenKey);

  Future<void> clearAccessToken() =>
      _localStorage.remove(AppConstants.tokenKey);
}
