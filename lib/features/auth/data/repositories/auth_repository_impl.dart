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
    } on NetworkException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      return Success(user);
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
    // TODO: check LocalStorage for cached token and return cached user
    return const Success(null);
  }
}
