import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/auth_interceptor.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';

class DioClient {
  late final Dio dio;

  DioClient(LocalStorage localStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    dio.interceptors.add(AuthInterceptor(localStorage));
    dio.interceptors.add(_ErrorInterceptor());
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
        if (statusCode == 401) throw const UnauthorisedException('Unauthorised');
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
