import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/auth_interceptor.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/core/network/dio_error_mapper.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/auth/data/models/login_response_model.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';

class _AppExceptionDio implements Dio {
  final Dio _delegate;

  _AppExceptionDio([BaseOptions? options]) : _delegate = Dio(options);

  @override
  BaseOptions get options => _delegate.options;

  @override
  set options(BaseOptions value) => _delegate.options = value;

  @override
  Interceptors get interceptors => _delegate.interceptors;

  @override
  HttpClientAdapter get httpClientAdapter => _delegate.httpClientAdapter;

  @override
  set httpClientAdapter(HttpClientAdapter value) => _delegate.httpClientAdapter = value;

  @override
  Transformer get transformer => _delegate.transformer;

  @override
  set transformer(Transformer value) => _delegate.transformer = value;

  @override
  void close({bool force = false}) => _delegate.close(force: force);

  @override
  Dio clone({
    BaseOptions? options,
    Interceptors? interceptors,
    HttpClientAdapter? httpClientAdapter,
    Transformer? transformer,
  }) =>
      _delegate.clone(
        options: options,
        interceptors: interceptors,
        httpClientAdapter: httpClientAdapter,
        transformer: transformer,
      );

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    try {
      return await _delegate.fetch<T>(requestOptions);
    } on DioException catch (e) {
      final error = e.error;
      if (error is AppException) {
        throw error;
      }
      rethrow;
    }
  }

  @override
  Future<Response<T>> get<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) =>
      _delegate.get<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> getUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onReceiveProgress}) =>
      _delegate.getUri<T>(uri, data: data, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> postUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.postUri<T>(uri, data: data, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> put<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.put<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> putUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.putUri<T>(uri, data: data, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> head<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _delegate.head<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> headUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) =>
      _delegate.headUri<T>(uri, data: data, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> delete<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _delegate.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> deleteUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) =>
      _delegate.deleteUri<T>(uri, data: data, options: options, cancelToken: cancelToken);

  @override
  Future<Response<T>> patch<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.patch<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> patchUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.patchUri<T>(uri, data: data, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> request<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, CancelToken? cancelToken, Options? options, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.request<T>(path, data: data, queryParameters: queryParameters, cancelToken: cancelToken, options: options, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response<T>> requestUri<T>(Uri uri, {Object? data, CancelToken? cancelToken, Options? options, ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) =>
      _delegate.requestUri<T>(uri, data: data, cancelToken: cancelToken, options: options, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) =>
      _delegate.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        fileAccessMode: fileAccessMode,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );

  @override
  Future<Response> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) =>
      _delegate.downloadUri(
        uri,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        fileAccessMode: fileAccessMode,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );
}

class DioClient {
  late final Dio dio;

  DioClient({
    required LocalStorage localStorage,
    required AuthTokenStorage authTokenStorage,
    required CookieJar cookieJar,
  }) {
    dio = _AppExceptionDio(
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

    if (!kIsWeb) {
      dio.interceptors.add(CookieManager(cookieJar));
    }

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    dio.interceptors.add(AuthInterceptor(localStorage));
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
  DioException _rejectWith(
    DioException err,
    Object error,
  ) {
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: error,
      message: err.message,
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          _rejectWith(err, const NetworkException('Connection timed out')),
        );
        return;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final message =
            extractApiMessage(err.response?.data) ?? 'Server error';
        if (statusCode == 401) {
          handler.reject(
            _rejectWith(err, UnauthorisedException(message)),
          );
          return;
        }
        handler.reject(
          _rejectWith(
            err,
            ServerException(message, statusCode: statusCode),
          ),
        );
        return;
      case DioExceptionType.connectionError:
        handler.reject(
          _rejectWith(err, const NetworkException('No internet connection')),
        );
        return;
      default:
        handler.reject(
          _rejectWith(
            err,
            NetworkException(err.message ?? 'Unexpected error'),
          ),
        );
    }
  }
}
