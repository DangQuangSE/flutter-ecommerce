import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/network/dio_error_mapper.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/data/models/user_model.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResponse = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _localDataSource.saveAccessToken(loginResponse.accessToken);
      try {
        final user = await _loadCurrentUser();
        return Success(user);
      } on AppException {
        await _localDataSource.clearSession();
        rethrow;
      }
    } on DioException catch (e) {
      return ResultFailure(failureFromDioException(e));
    } on UnauthorisedException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    if (_localDataSource.getAccessToken() == null) {
      return const Success(null);
    }

    try {
      final user = await _loadCurrentUser();
      return Success(user);
    } on UnauthorisedException {
      try {
        final refreshed = await _remoteDataSource.refreshAccessToken();
        await _localDataSource.saveAccessToken(refreshed.accessToken);
        final user = await _loadCurrentUser();
        return Success(user);
      } on AppException {
        await _localDataSource.clearSession();
        return const Success(null);
      }
    } on AppException {
      await _localDataSource.clearSession();
      return const Success(null);
    } on DioException {
      await _localDataSource.clearSession();
      return const Success(null);
    }
  }

  Future<UserEntity> _loadCurrentUser() async {
    final me = await _remoteDataSource.fetchMe();
    return UserModel.fromAuthMe(me);
  }

  @override
  Future<Result<void>> requestRegistrationOtp({required String email}) async {
    return _voidResult(() => _remoteDataSource.requestRegistrationOtp(email: email));
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _voidResult(
      () => _remoteDataSource.verifyOtp(email: email, otp: otp),
    );
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
  }) async {
    return _voidResult(
      () => _remoteDataSource.register(email: email, password: password),
    );
  }

  @override
  Future<Result<void>> resendOtp({required String email}) async {
    return _voidResult(() => _remoteDataSource.resendOtp(email: email));
  }

  Future<Result<void>> _voidResult(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } on DioException catch (e) {
      return ResultFailure(failureFromDioException(e));
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } on AppException {
      // Still clear local session if server logout fails.
    } finally {
      await _localDataSource.clearSession();
    }
    return const Success(null);
  }
}
