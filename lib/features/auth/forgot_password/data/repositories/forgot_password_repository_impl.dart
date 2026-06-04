import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/network/dio_error_mapper.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final ForgotPasswordRemoteDataSource _remoteDataSource;

  const ForgotPasswordRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<String>> requestOtp({required String email}) async {
    return _stringResult(() => _remoteDataSource.requestOtp(email: email));
  }

  @override
  Future<Result<String>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    return _stringResult(
      () => _remoteDataSource.verifyOtp(email: email, otpCode: otpCode),
    );
  }

  @override
  Future<Result<void>> resetPassword({
    required String forgotPasswordToken,
    required String newPassword,
  }) async {
    return _voidResult(
      () => _remoteDataSource.resetPassword(
        forgotPasswordToken: forgotPasswordToken,
        newPassword: newPassword,
      ),
    );
  }

  Future<Result<String>> _stringResult(Future<String> Function() action) async {
    try {
      final value = await action();
      return Success(value);
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
}
