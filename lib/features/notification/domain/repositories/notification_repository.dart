import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';

abstract interface class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications();
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
}
