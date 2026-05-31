# Phase 2: Core Layer

## Requirements
Build the shared `core/` infrastructure that every feature depends on: a typed error/result system, a configured Dio HTTP client with interceptors, a SharedPreferences storage wrapper, constants, and context/string extensions. No feature code lives here — only reusable building blocks.

## Steps
1. Create `core/errors/` with a sealed `Result<T>` type, a `Failure` sealed class hierarchy, and an `AppException` hierarchy — these become the universal return types for all repository and use-case methods.
2. Create `core/network/dio_client.dart` with a Dio instance pre-configured with base URL, JSON content-type headers, a logging interceptor for debug builds, and an error-mapping interceptor that converts Dio errors to `AppException` types.
3. Create `core/storage/local_storage.dart` as a thin async wrapper around `SharedPreferences` with typed get/set/remove methods.
4. Create `core/constants/api_constants.dart` and `app_constants.dart` for base URL and app-wide magic values.
5. Create `core/utils/extensions/` with a `context_extensions.dart` (theme/media query shortcuts) and `string_extensions.dart` (capitalization, null-safety helpers).
6. Register `DioClient` and `LocalStorage` as lazy singletons in the existing `core/di/injection_container.dart` stub from Phase 1.

## Success Criteria
- `flutter analyze lib/core/` returns 0 issues
- `DioClient` can be retrieved via `sl<DioClient>()` in a test entry point without throwing
- All `Result<T>` subclasses pattern-match exhaustively in a `switch` expression without a default arm

## Risks
- Dio version 5.x removed `BaseOptions.baseUrl` validation — ensure base URL does not have a trailing slash or Dio will double-slash API paths
- `SharedPreferences` is async to initialize — `LocalStorage` must be initialized before `configureDependencies()` returns; use `await` in `injection_container.dart`

---

## Exact File Contents

### `lib/core/errors/failures.dart`

```dart
import 'package:equatable/equatable.dart';

/// Base sealed class for all domain-level failures.
/// Use in repository return types: `Future<Result<T>>`.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// HTTP or network-level failure (4xx, 5xx, timeout, no connection).
final class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Data could not be parsed or is in an unexpected shape.
final class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

/// Locally stored data is missing or corrupted.
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Business rule violation (e.g., out of stock, insufficient balance).
final class DomainFailure extends Failure {
  const DomainFailure(super.message);
}

/// Authentication / authorisation failure (401 / 403).
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
```

### `lib/core/errors/exceptions.dart`

```dart
/// Base class for all data-layer exceptions.
/// Thrown by datasources; caught and converted to [Failure] in repositories.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

final class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode});
}

final class ParseException extends AppException {
  const ParseException(super.message);
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class UnauthorisedException extends AppException {
  const UnauthorisedException(super.message);
}

final class ServerException extends AppException {
  final int statusCode;
  const ServerException(super.message, {required this.statusCode});
}
```

### `lib/core/errors/result.dart`

```dart
// lib/core/errors/result.dart
import 'package:flutter_ecommerce/core/errors/failures.dart' as failures;

/// Dart 3 sealed Result type — replaces dartz/Either for this project.
///
/// Usage:
///   Future<Result<User>> getUser() async {
///     try { return Success(await api.fetchUser()); }
///     catch (_) { return ResultFailure(NetworkFailure('unreachable')); }
///   }
///
/// Consumption (exhaustive switch — no default needed):
///   switch (result) {
///     case Success(:final data) => print(data),
///     case ResultFailure(:final failure) => print(failure.message),
///   }
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Named ResultFailure (not Failure) to avoid name collision with failures.Failure.
final class ResultFailure<T> extends Result<T> {
  final failures.Failure failure;
  const ResultFailure(this.failure);
}
```

### `lib/core/constants/api_constants.dart`

```dart
abstract final class ApiConstants {
  // Replace with actual base URL before connecting to a real backend.
  static const String baseUrl = 'https://api.flutter-ecommerce.dev/v1';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
}
```

### `lib/core/constants/app_constants.dart`

```dart
abstract final class AppConstants {
  static const String appName = 'Flutter E-Commerce';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
  static const int defaultPageSize = 20;
}
```

### `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;

  /// Attach (or remove) the Bearer token after login/logout.
  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException mapped;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        mapped = const NetworkException('Request timed out');
      case DioExceptionType.connectionError:
        mapped = const NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        if (statusCode == 401) {
          mapped = const UnauthorisedException('Unauthorised — please log in again');
        } else {
          mapped = ServerException(
            err.response?.data?['message']?.toString() ?? 'Server error',
            statusCode: statusCode,
          );
        }
      default:
        mapped = NetworkException(err.message ?? 'Unknown network error');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: mapped,
        message: mapped.message,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
```

### `lib/core/storage/local_storage.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  const LocalStorage(this._prefs);

  // ── String ──────────────────────────────────────────────────────────────────

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // ── Bool ────────────────────────────────────────────────────────────────────

  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  // ── Int ─────────────────────────────────────────────────────────────────────

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  // ── Removal ─────────────────────────────────────────────────────────────────

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();

  bool containsKey(String key) => _prefs.containsKey(key);
}
```

### `lib/core/utils/extensions/context_extensions.dart`

```dart
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}
```

### `lib/core/utils/extensions/string_extensions.dart`

```dart
extension StringExtensions on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalised).join(' ');

  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  bool get isValidPassword => length >= 8;
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  String get orEmpty => this ?? '';
}
```

### Updated `lib/core/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorage(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Feature registrations are added in Phase 4.
}
```

## Checklist

- [ ] Create `lib/core/errors/failures.dart`
- [ ] Create `lib/core/errors/exceptions.dart`
- [ ] Create `lib/core/errors/result.dart` (use `ResultFailure` to avoid name collision)
- [ ] Create `lib/core/constants/api_constants.dart`
- [ ] Create `lib/core/constants/app_constants.dart`
- [ ] Create `lib/core/network/dio_client.dart`
- [ ] Create `lib/core/storage/local_storage.dart`
- [ ] Create `lib/core/utils/extensions/context_extensions.dart`
- [ ] Create `lib/core/utils/extensions/string_extensions.dart`
- [ ] Update `lib/core/di/injection_container.dart` with SharedPreferences, LocalStorage, DioClient registrations
- [ ] Create empty placeholder files: `lib/core/widgets/.gitkeep` (directory must exist for spec FR compliance)
- [ ] Run `flutter analyze lib/core/` — 0 issues
