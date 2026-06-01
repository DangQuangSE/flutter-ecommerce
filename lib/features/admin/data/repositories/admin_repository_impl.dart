import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;
  const AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<AdminStatsEntity>> getAdminStats() async {
    try {
      final stats = await _remoteDataSource.getAdminStats();
      return Success(stats);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }
}
