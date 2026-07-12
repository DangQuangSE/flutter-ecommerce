import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import '../datasources/admin_remote_datasource.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/admin_notification_model.dart';
import '../../domain/entities/revenue_analytics_entity.dart';

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
  @override
  Future<Result<List<AdminNotificationModel>>> getAdminNotifications() async {
    try {
      final notifications = await _remoteDataSource.getAdminNotifications();
      return Success(notifications);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllAdminNotificationsAsRead() async {
    try {
      await _remoteDataSource.markAllNotificationsAsRead();
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }
  @override
  Future<Result<RevenueAnalyticsEntity>> getRevenueAnalytics(DateTime start, DateTime end) async {
    try { return Success(await _remoteDataSource.getRevenueAnalytics(start, end)); }
    on AppException catch (e) { return ResultFailure(NetworkFailure(e.message)); }
    catch (e) { return ResultFailure(NetworkFailure(e.toString())); }
  }
}
