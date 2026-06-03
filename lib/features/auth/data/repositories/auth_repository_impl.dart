import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(email: email, password: password);
      return Success(user);
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
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    return const Success(null);
  }
}
