import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_ecommerce/features/notification/data/datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await _remoteDataSource.getNotifications();
      return Success(notifications);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead(int id) async {
    try {
      await _remoteDataSource.markAsRead(id);
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
      return const Success(null);
    } on AppException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(NetworkFailure(e.toString()));
    }
  }
}
