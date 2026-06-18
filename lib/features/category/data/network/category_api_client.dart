import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

/// Dio client for the real Sport Pro backend (category endpoints).
///
/// Self-contained inside the category module (its own [Dio] instance). For
/// admin writes (`POST/PUT/DELETE/PATCH /api/admin/categories`) it attaches the
/// Bearer token saved by the app's real login under [AppConstants.tokenKey];
/// reads (`GET /api/categories`) are public and need no token.
class CategoryApiClient {
  late final Dio dio;
  final LocalStorage _storage;

  String? _token;

  CategoryApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _ensureToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          // Token expired/invalid → refresh once and retry the request.
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra['__retried'] != true) {
            _token = null;
            final token = await _ensureToken();
            if (token != null && token.isNotEmpty) {
              final opts = e.requestOptions
                ..extra['__retried'] = true
                ..headers['Authorization'] = 'Bearer $token';
              try {
                return handler.resolve(await dio.fetch(opts));
              } catch (err) {
                return handler.next(err is DioException ? err : e);
              }
            }
          }
          handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    dio.interceptors.add(_ErrorInterceptor());
  }

  /// Resolves a Bearer token: in-memory cache → token saved by the app's real
  /// login (under [AppConstants.tokenKey]). Returns null when not logged in —
  /// public reads still work; admin writes then get 401 until the user logs in.
  Future<String?> _ensureToken() {
    if (_token != null && _token!.isNotEmpty) return Future.value(_token);

    final stored = _storage.getString(AppConstants.tokenKey);
    if (stored != null && stored.isNotEmpty) {
      _token = stored;
    }
    return Future.value(_token);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException appEx;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appEx = const NetworkException('Hết thời gian kết nối tới máy chủ');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        final message = (data is Map && data['message'] is String)
            ? data['message'] as String
            : 'Lỗi máy chủ';
        appEx = (statusCode == 401 || statusCode == 403)
            ? UnauthorisedException(message)
            : ServerException(message, statusCode: statusCode);
      case DioExceptionType.connectionError:
        appEx = const NetworkException('Không thể kết nối tới máy chủ');
      default:
        appEx = NetworkException(err.message ?? 'Lỗi không xác định');
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appEx,
      ),
    );
  }
}
