import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';

class AuthLocalDataSource {
  final AuthTokenStorage _tokenStorage;
  final CookieJar _cookieJar;

  const AuthLocalDataSource(this._tokenStorage, this._cookieJar);

  Future<void> saveAccessToken(String token) => _tokenStorage.saveAccessToken(token);

  String? getAccessToken() => _tokenStorage.getAccessToken();

  Future<void> clearSession() async {
    await _tokenStorage.clearAccessToken();
    await _cookieJar.deleteAll();
  }
}
