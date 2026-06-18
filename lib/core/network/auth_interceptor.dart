import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  AuthInterceptor(this._localStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _localStorage.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      // Do not dispatch logout for:
      // - login path (would overwrite AuthLoginFailed with logout)
      // - refresh-token path (_AuthRefreshInterceptor owns that lifecycle)
      if (path != ApiConstants.login &&
          path != ApiConstants.refreshToken) {
        GetIt.instance<AuthBloc>().add(const AuthLogoutRequested());
      }
    }
    handler.next(err);
  }
}
