import 'dart:io';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_ecommerce/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_ecommerce/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<ProfileEntity>> getMyProfile() {
    return _guard(() => _remoteDataSource.getMyProfile());
  }

  @override
  Future<Result<ProfileEntity>> updateProfile({
    required String firstName,
    required String lastName,
  }) {
    return _guard(() => _remoteDataSource.updateProfile(
          firstName: firstName,
          lastName: lastName,
        ));
  }

  @override
  Future<Result<ProfileEntity>> updateAvatar(File image) {
    return _guard(() => _remoteDataSource.updateAvatar(image));
  }

  /// Runs [action], mapping known exceptions to the corresponding [Failure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on UnauthorisedException catch (e) {
      return ResultFailure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
    } on ParseException catch (e) {
      return ResultFailure(ParseFailure(e.message));
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    }
  }
}
