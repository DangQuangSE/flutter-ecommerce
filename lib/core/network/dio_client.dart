import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/auth/data/models/login_response_model.dart';

class DioClient {
  late final Dio dio;

  DioClient({
    required AuthTokenStorage authTokenStorage,
    required CookieJar cookieJar,
  }) {
    dio = Dio(
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

    dio.interceptors.add(CookieManager(cookieJar));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    dio.interceptors.add(
      _AuthRefreshInterceptor(dio: dio, authTokenStorage: authTokenStorage),
    );
    dio.interceptors.add(_ErrorInterceptor());
  }
}

class _AuthRefreshInterceptor extends QueuedInterceptor {
  _AuthRefreshInterceptor({
    required Dio dio,
    required AuthTokenStorage authTokenStorage,
  })  : _dio = dio,
        _authTokenStorage = authTokenStorage;

  final Dio _dio;
  final AuthTokenStorage _authTokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == ApiConstants.login ||
        options.path == ApiConstants.refreshToken) {
      handler.next(options);
      return;
    }
    final token = _authTokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final alreadyRetried = err.requestOptions.extra['_retried'] == true;

    if (statusCode == 401 &&
        !alreadyRetried &&
        path != ApiConstants.login &&
        path != ApiConstants.refreshToken) {
      try {
        final refreshResponse = await _dio.post<Map<String, dynamic>>(
          ApiConstants.refreshToken,
          options: Options(extra: {'_skipRefresh': true}),
        );
        final loginModel =
            LoginResponseModel.fromApiResponse(refreshResponse.data!);
        await _authTokenStorage.saveAccessToken(loginModel.accessToken);

        final retryOptions = err.requestOptions;
        retryOptions.extra['_retried'] = true;
        retryOptions.headers['Authorization'] =
            'Bearer ${loginModel.accessToken}';

        final retryResponse = await _dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _authTokenStorage.clearAccessToken();
      }
    }

    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException('Connection timed out');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        if (statusCode == 401) {
          throw UnauthorisedException(
            err.response?.data?['message'] as String? ?? 'Unauthorised',
          );
        }
        throw ServerException(
          err.response?.data?['message'] as String? ?? 'Server error',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        throw const NetworkException('No internet connection');
      default:
        throw NetworkException(err.message ?? 'Unexpected error');
    }
  }
}
